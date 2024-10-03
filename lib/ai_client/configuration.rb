# ai_client/configuration.rb

require 'logger'

class AiClient
  # TODO: Need a centralized service where
  #       metadata about LLMs are available
  #       via and API call.  Would hope that
  #       the providers would add a "list"
  #       endpoint to their API which would
  #       return the metadata for all of their
  #       models.

  PROVIDER_PATTERNS = {
    anthropic:  /^claude/i,
    openai:     /^(gpt|davinci|curie|babbage|ada|whisper|tts|dall-e)/i,
    google:     /^(gemini|palm)/i,
    mistral:    /^(mistral|codestral)/i,
    localai:    /^local-/i,
    ollama:     /(llama-|nomic)/i
  }

  MODEL_TYPES = {
    text_to_text:   /^(nomic|gpt|davinci|curie|babbage|ada|claude|gemini|palm|command|generate|j2-|mistral|codestral)/i,
    speech_to_text: /^whisper/i,
    text_to_speech: /^tts/i,
    text_to_image:  /^dall-e/i
  }

  class << self

    def configure
      yield(configuration)
    end

    def configuration
      @configuration ||= Configuration.new
    end

  end




  # Usage example:
  # Configure general settings
  #   AiClient.configure do |config|
  #     config.logger = Logger.new('ai_client.log')
  #     config.return_raw = true
  #   end
  #
  # Configure provider-specific settings
  #   AiClient.configure do |config|
  #     config.configure_provider(:openai) do
  #       {
  #         organization: 'org-123',
  #         api_version: 'v1'
  #       }
  #     end
  #   end
  #

  class Configuration
    attr_accessor :logger, :timeout, :return_raw
    attr_reader :providers, :provider_patterns, :model_types

    def initialize
      @logger             = Logger.new(STDOUT)
      @timeout            = nil
      @return_raw         = false
      @providers          = {}
      @provider_patterns  = AiClient::PROVIDER_PATTERNS.dup
      @model_types        = AiClient::MODEL_TYPES.dup
    end

    def provider(name, &block)
      if block_given?
        @providers[name] = block
      else
        @providers[name]&.call || {}
      end
    end
  end
end