# ai_client/configuration.rb
#
# Design Objective:
# AiClient.configure do |config|
#   # global config items that over-ride the defaults
# end
#
# client = AiClient.new(...) do
#   # client specific config items that over-ride the global config
# end 

require 'hashie'
require 'logger'

class AiClient
  # TODO: Use system environment varibles
  #       AI_CLIENT_CONFIG_FILE
  #
  # TODO: Config.load('path/to/some_file.yml')
  #         @@default_config (on require from lib/config.yml)
  #         @@config (if the envar exists ?? merge with default)
  #         @config ... done

  class Config < Hashie::Mash
    include Hashie::Extensions::Mash::PermissiveRespondTo
    include Hashie::Extensions::Mash::SymbolizeKeys
    include Hashie::Extensions::Mash::DefineAccessors
  end


  # Class variables to hold default and current config
  @@default_config = Config.new(
    logger: Logger.new(STDOUT),
    timeout: nil,
    return_raw: false,
    providers: {},
    provider_patterns: {
      anthropic: /^claude/i,
      openai: /^(gpt|davinci|curie|babbage|ada|whisper|tts|dall-e)/i,
      google: /^(gemini|palm)/i,
      mistral: /^(mistral|codestral)/i,
      localai: /^local-/i,
      ollama: /(llama|nomic)/i
    },
    model_types: {
      text_to_text: /^(nomic|gpt|davinci|curie|babbage|ada|claude|gemini|palm|command|generate|j2-|mistral|codestral)/i,
      speech_to_text: /^whisper/i,
      text_to_speech: /^tts/i,
      text_to_image: /^dall-e/i
    }
  )

  @@config = @@default_config.dup

  class << self
    def configure(&block)
      yield(config)
    end

    def config
      @@config
    end

    def default_config
      @@default_config
    end
  end
end
