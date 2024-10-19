# lib/ai_client/open_router_extensions.rb

# These extensions to AiClient utilize the AiClient::LLM class
# and the models.yml file for model information

require 'open_router'
require 'yaml'

class AiClient

  # Retrieves details for the current model.
  #
  # @return [Hash, nil] Details of the current model or nil if not found.
  def model_details
    id = "#{@provider}/#{@model}"
    AiClient::LLM.find(id)&.attributes
  end

  # Retrieves model names for the current provider.
  #
  # @return [Array<String>] List of model names for the current provider.
  def models = self.class.models(provider: @provider)


  class << self

    # Retrieves all available providers.
    #
    # @return [Array<Symbol>] List of all provider names.
    def providers
      AiClient::LLM.all.map(&:provider).uniq.map(&:to_sym)
    end

    # Retrieves model names, optionally filtered by provider.
    #
    # @param provider [String, nil] The provider to filter models by.
    # @return [Array<String>] List of model names.
    def models(provider: nil)
      models = AiClient::LLM.all
      models = models.select { |m| m.id.starts_with?(provider.to_s) } if provider
      provider.nil? ? models.map(&:id) : models.map(&:model)
    end

    # Retrieves details for a specific model.
    #
    # @param a_model [String] The model ID to retrieve details for.
    # @return [Hash, nil] Details of the model or nil if not found.
    def model_details(a_model)
      AiClient::LLM.find(a_model)&.attributes
    end

    # Finds models matching a given substring.
    #
    # @param a_model_substring [String] The substring to search for.
    # @return [Array<String>] List of matching model names.
    def find_model(a_model_substring)
      AiClient::LLM.where(id: /#{a_model_substring}/i).pluck(:id)
    end
  

    # Adds OpenRouter extensions to AiClient.
    #
    # @return [void]
    #
    def add_open_router_extensions
      access_token = fetch_access_token

      return unless access_token

      configure_open_router(access_token)
      initialize_orc_client
    end

    # Retrieves ORC client instance.
    #
    # @return [OpenRouter::Client] Instance of the OpenRouter client.
    #
    def orc_client
      @orc_client ||= add_open_router_extensions || raise("OpenRouter extensions are not available")
    end

    # Retrieves models from the ORC client.
    #
    # @return [Array<Hash>] List of models.
    #
    def orc_models
      @orc_models ||= orc_client.models
    end


    # Resets LLM data with the available ORC models.
    #
    # @return [void]
    #
    def reset_llm_data
      LLM.data = orc_models
      LLM::DATA_PATH.write(orc_models.to_yaml)
    end


    private

    # Fetches the access token from environment variables.
    #
    # @return [String, nil] The access token or nil if not found.
    #
    def fetch_access_token
      class_config.envar_api_key_names.open_router
                  .map { |key| ENV[key] }
                  .compact
                  .first
    end

    # Configures the OpenRouter client with the access token.
    #
    # @param access_token [String] The access token to configure.
    # @return [void]
    #
    def configure_open_router(access_token)
      OpenRouter.configure { |config| config.access_token = access_token }
    end

    # Initializes the ORC client.
    #
    # @return [OpenRouter::Client] Instance of the OpenRouter client.
    def initialize_orc_client
      @orc_client ||= OpenRouter::Client.new
    end
  end
end

AiClient.add_open_router_extensions
