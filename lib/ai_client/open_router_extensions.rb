# lib/ai_client/open_router_extensions.rb
# frozen_string_literal: true

# These extensions to AiClient are only available with
# a valid API Key for the open_router.ai web-service

require 'open_router'
require 'yaml'

class AiClient
  
  # Retrieves the available models.
  #
  # @return [Array<String>] List of model IDs.
  #
  def models
    self.class.models
  end

  # Retrieves the available providers.
  #
  # @return [Array<String>] List of provider names.
  def providers
    self.class.providers
  end

  # Retrieves model names, optionally filtered by provider.
  #
  # @param provider [String, nil] The provider to filter models by.
  # @return [Array<String>] List of model names.
  def model_names(provider = nil)
    self.class.model_names(provider)
  end

  # Retrieves details for a specific model.
  #
  # @param a_model [String] The model ID to retrieve details for.
  # @return [Hash, nil] Details of the model or nil if not found.
  def model_details(a_model)
    self.class.model_details(a_model)
  end

  # Finds models matching a given substring.
  #
  # @param a_model_substring [String] The substring to search for.
  # @return [Array<String>] List of matching model names.
  def find_model(a_model_substring)
    self.class.find_model(a_model_substring)
  end


  class << self
    
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

    # TODO: Refactor these DB like methods to take
    #       advantage of AiClient::LLM

    # Retrieves model names associated with a provider.
    #
    # @param provider [String, nil] The provider to filter models by.
    # @return [Array<String>] List of model names.
    #
    def model_names(provider=nil)
      model_ids = models.map { _1['id'] }

      return model_ids unless provider

      model_ids.filter_map { _1.split('/')[1] if _1.start_with?(provider.to_s.downcase) }
    end

    # Retrieves details of a specific model.
    #
    # @param model [String] The model ID to retrieve details for.
    # @return [Hash, nil] Details of the model or nil if not found.
    #
    def model_details(model)
      orc_models.find { _1['id'].include?(model) }
    end

    # Retrieves the available providers.
    #
    # @return [Array<String>] List of unique provider names.
    #
    def providers
      @providers ||= models.map{ _1['id'].split('/')[0] }.sort.uniq      
    end

    # Finds models matching a given substring.
    #
    # @param a_model_substring [String] The substring to search for.
    # @return [Array<String>] List of matching model names.
    #
    def find_model(a_model_substring)
      model_names.select{ _1.include?(a_model_substring) }
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
    # @return [void]
    #
    def initialize_orc_client
      @orc_client ||= OpenRouter::Client.new
    end
  end
end

AiClient.add_open_router_extensions
