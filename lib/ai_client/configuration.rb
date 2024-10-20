# ai_client/configuration.rb
#
# AiClient and AiClient::Config
#
# The AiClient class provides a configurable client for interacting with various AI service providers.
# It allows users to set global configurations and provider-specific settings via a block.
#
# There are three levels of configuration:
#   * default_config .. the starting point
#   * class_config .... for all instances
#   * config .......... for an instance
# 
# Class Configuration
#   starts with the default configuration but can
#   be changed in three different ways.
#   1. Use the configuration block
#       AiClient.configuration do |config|
#         some_item = some_value
#         ...
#       end
#
#   2.  Automatic YAML configuration file
#       Set the system environment variable AI_CLIENT_CONFIG_FILE
#       to an existing configuration file.  The contents of that
#       file will be automatically merged on top of the
#       default configuration.
#
#   3.  Manual YAML configuration file
#       You can completely replace the class configuration
#         AiClient.class_config = AiClient::Config.load('path/to/file.yml')
#       You can supplement the existing class config
#         AiClient.class_config.merge!(AiClient::Config.load('path/to/file.yml'))
#
# Instance Configuration
#   AiClient is setup so that you can have multiple instance
#   of clients each using a different model / provider and having
#   a different configuration.  There are several ways you
#   can manipulate an instance's configuration.
# 
#   1.  The default instance configuration inherents from the
#       the class configuration.
#         client = AiClient.new('your_model')
#       You can access the instance configuration using
#         client.config.some_item
#         client.config[:some_item]
#         client.config['some_item']
#       All three ways returns the value for that configuration item.
#       To change the value of an item its also that simple.
#         client.config.some_item     = some_value
#         client.config[:some_item]   = some_value
#         client.config['some_item']  = some_value
#   2.  Instance constructor block
#         client = AiClient.new('your_model') do |config|
#           config.some_item = some_value
#           ...
#         end
#
#   3.  Like the class configuration you can can replace or
#       supplement an instance's configuration from a YAML file.
#         client = AiClient.new('your_model', config: 'path/to/file.yml')
#         client.config.merge!(AiClient::Config.load('path/to/file.yml'))
#       Both of those example suppliment / over0ride items in
#       the class configuration to become the instance's
#       configuration.  To completely replace the instance's
#       configuration you can do this.
#         client = AiClient.new('your_model')
#         client.config = AiClient::Config.load('path/to/file.yml')
#
# OmniAI Configuration Items
# OmniAI::OpenAI
#   config.api_key = '...'
#   config.host = 'http://localhost:8080'
#   config.logger = Logger.new(STDOUT)
#   config.timeout = 15
#   config.chat_options = { ... }
#   config.transcribe_options = { ... }
#   config.speak_options = { ... }
#



require 'hashie'
require 'logger'
require 'yaml'
require 'pathname'

class AiClient
  class Config < Hashie::Mash
    DEFAULT_CONFIG_FILEPATH = Pathname.new(__dir__) + 'config.yml'
    
    include Hashie::Extensions::Mash::PermissiveRespondTo
    include Hashie::Extensions::Mash::SymbolizeKeys
    include Hashie::Extensions::Mash::DefineAccessors

    # Saves the current configuration to the specified file.
    #
    # @param filepath [String] The path to the file where the configuration will be saved.
    #   Defaults to '~/aiclient_config.yml' if not provided.
    #
    def save(filepath=ENV['HOME']+'/aiclient_config.yml')
      filepath = Pathname.new(filepath) unless filepath.is_a? Pathname

      filepath.write(YAML.dump(to_hash))
    end


    class << self
      # Loads configuration from the specified YAML file.
      #
      # @param filepath [String] The path to the configuration file.
      #   Defaults to 'config.yml' if not provided.
      # @return [AiClient::Config] The loaded configuration.
      # @raise [ArgumentError] If the specified file does not exist.
      #
      def load(filepath=DEFAULT_CONFIG_FILEPATH)
        filepath = Pathname.new(filepath) unless Pathname == filepath.class
        if filepath.exist?
          new(YAML.parse(filepath.read).to_ruby)
        else
          raise ArgumentError, "#{filepath} does not exist"
        end
      end
    end
  end

  class << self
    attr_accessor :class_config, :default_config

    # Configures the AiClient with a given block.
    #
    # @yieldparam config [AiClient::Config] The configuration instance.
    # @return [void]
    #
    def configure(&block)
      yield(class_config)
    end

    # Resets the default configuration to the value defined in the class.
    #
    # @return [void]
    #
    def reset_default_config
      initialize_defaults
        .save(Config::DEFAULT_CONFIG_FILEPATH)      
    end

    private
    
    # Initializes the default configuration.
    #
    # @return [void]
    #
    def initialize_defaults
      @default_config = Config.new(
        logger: Logger.new(STDOUT), # TODO: drop the logger as a default
        timeout: nil,
        return_raw: false,
        context_length: 5, # number of responses to add as context
        providers: {},
        envar_api_key_names: {
          anthropic: ['ANTHROPIC_API_KEY'],
          google: ['GOOGLE_API_KEY'],
          mistral: ['MISTRAL_API_KEY'],
          open_router: ['OPEN_ROUTER_API_KEY', 'OPENROUTER_API_KEY'],
          openai: ['OPENAI_API_KEY']
        },
        provider_patterns: {
          anthropic: /^claude/i,
          openai: /^(gpt|chatgpt|o1|davinci|curie|babbage|ada|whisper|tts|dall-e)/i,
          google: /^(gemini|gemma|palm)/i,
          mistral: /^(mistral|codestral|mixtral)/i,
          localai: /^local-/i,
          ollama: /(llama|nomic)/i,
          open_router: /\//
        }
      )

      @class_config = @default_config.dup
    end
  end

  initialize_defaults
end


AiClient.default_config = AiClient::Config.load
AiClient.class_config   = AiClient.default_config.dup

if config_file = ENV.fetch('AI_CLIENT_CONFIG_FILE', nil)
  AiClient.class_config.merge!(AiClient::Config.load(config_file))
end
