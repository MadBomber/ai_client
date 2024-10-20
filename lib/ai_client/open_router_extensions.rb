# lib/ai_client/open_router_extensions.rb

# OpenRouter Extensions for AiClient
#
# This file adds several public instance and class methods to the AiClient class
# to provide information about AI models and providers.
#
# Instance Methods:
# - model_details: Retrieves details for the current model.
# - models: Retrieves model names for the current provider.
#
# Class Methods:
# - providers: Retrieves all available providers.
# - models: Retrieves model names, optionally filtered by provider.
# - model_details: Retrieves details for a specific model.
#
# These methods utilize the AiClient::LLM class and the models.yml file
# for model information.

require 'open_router'
require 'yaml'

class AiClient

  # Retrieves details for the current model.
  #
  # @return [Hash, nil] Details of the current model or nil if not found.
  def model_details
    id = "#{@provider}/#{@model}"
    LLM.find(id.downcase)
  end

  # Retrieves model names for the current provider.
  #
  # @return [Array<String>] List of model names for the current provider.
  def models = LLM.models(@provider)


  class << self

    # Retrieves all available providers.
    #
    # @return [Array<Symbol>] List of all provider names.
    def providers = LLM.providers


    # Retrieves model names, optionally filtered by provider.
    #
    # @param substring [String, nil] Optional substring to filter models by.
    # @return [Array<String>] List of model names.
    def models(substring = nil) = LLM.models(substring)

    # Retrieves details for a specific model.
    #
    # @param model_id [String] The model ID to retrieve details for,
    #     in the pattern "provider/model".downcase
    # @return [AiClient::LLM, nil] Details of the model or nil if not found.
    def model_details(model_id) = LLM.find(model_id.downcase)


    # Resets LLM data with the available ORC models.
    #
    # @return [void]
    #
    def reset_llm_data = LLM.reset_llm_data


    # Initializes OpenRouter extensions for AiClient.
    #
    # This sets up the access token and initializes the ORC client.
    # 
    # @return [void]
    #
    def add_open_router_extensions
      access_token = fetch_access_token

      return unless access_token

      configure_open_router(access_token)
      initialize_orc_client
    end


    private

    # Retrieves the ORC client instance.
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

    # Initializes the ORC client instance.
    #
    # @return [OpenRouter::Client] Instance of the OpenRouter client.
    def initialize_orc_client
      @orc_client ||= OpenRouter::Client.new
    end
  end
end

AiClient.add_open_router_extensions
