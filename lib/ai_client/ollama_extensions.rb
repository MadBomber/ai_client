# lib/ai_client/ollama_extensions.rb

# Ollama Extensions for AiClient
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

# TODO: consider incorporating Ollama AI extensions
# require 'ollama-ai'

require 'yaml'
require 'uri'
require 'json'
require 'net/http'

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
    def reset_llm_data
      # Simply delegate to LLM class if it has the method
      if LLM.respond_to?(:reset_llm_data)
        LLM.reset_llm_data
      end
    end


    # Initializes Ollama extensions for AiClient.
    #
    # This sets up the access token and initializes the ORC client.
    #
    # @return [void]
    #
    def add_ollama_extensions
      access_token = fetch_access_token

      return unless access_token

      configure_ollama(access_token)
      initialize_ollama_client
    end


    # Retrieves the ORC client instance.
    #
    # @return [Ollama::Client] Instance of the Ollama client.
    #
    def ollama_client
      @ollama_client ||= initialize_ollama_client
    end


    # Retrieves the available models from the Ollama server.
    #
    # @param host [String] Optional host URL for the Ollama server.
    #        Defaults to the configured host or http://localhost:11434 if not specified.
    # @return [Array<Hash>] List of available models with their details.
    #
    def ollama_available_models(host = nil)
      host ||= ollama_host

      uri = URI("#{host}/api/tags")
      response = Net::HTTP.get_response(uri)

      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)["models"] rescue []
      else
        []
      end
    end

    # Gets the configured Ollama host URL
    #
    # @return [String] The configured Ollama host URL
    def ollama_host
      class_config.providers[:ollama]&.dig(:host) || 'http://localhost:11434'
    end

    # Checks if a specific model exists on the Ollama server.
    #
    # @param model_name [String] The name of the model to check.
    # @param host [String] Optional host URL for the Ollama server.
    #        Defaults to the configured host or http://localhost:11434 if not specified.
    # @return [Boolean] True if the model exists, false otherwise.
    #
    def ollama_model_exists?(model_name, host = nil)
      models = ollama_available_models(host)
      models.any? { |m| m['name'] == model_name }
    end


    private


    # Retrieves models from the ORC client.
    #
    # @return [Array<Hash>] List of models.
    #
    def ollama_models
      []  # Simply return an empty array since we're not using the actual Ollama gem
    end


    # Fetches the access token from environment variables.
    #
    # @return [String, nil] The access token or nil if not found.
    #
    def fetch_access_token
      # Check if the key exists in the configuration
      return nil unless class_config.envar_api_key_names && 
                       class_config.envar_api_key_names[:ollama]
      
      # Now safely access the array
      class_config.envar_api_key_names[:ollama]
                  .map { |key| ENV[key] }
                  .compact
                  .first
    end

    # Configures the Ollama client with the access token.
    #
    # @param access_token [String] The access token to configure.
    # @return [void]
    #
    def configure_ollama(access_token)
      # No-op since we're not using the actual Ollama gem
    end

    # Initializes the ORC client instance.
    #
    # @return [OmniAI::Ollama::Client] Instance of the Ollama client.
    def initialize_ollama_client
      # Return a dummy object that won't raise errors
      Object.new
    end
  end
end

# Don't try to initialize the Ollama extensions at load time
# because we're not requiring the Ollama gem
# AiClient.add_ollama_extensions
