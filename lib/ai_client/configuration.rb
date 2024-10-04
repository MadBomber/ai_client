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
  # Class variables to hold default and current config
  @@default_config = Hashie::Mash.new(
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
      ollama: /(llama-|nomic)/i
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
