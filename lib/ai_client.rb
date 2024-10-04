# ai_client.rb
# WIP:  a generic client to access LLM providers
#       kinda like the SaaS "open router"
#

unless defined?(DebugMe)
  require 'debug_me'
  include DebugMe
end

require 'omniai'
require 'omniai/anthropic'
require 'omniai/google'
require 'omniai/mistral'
require 'omniai/openai'
require_relative 'extensions/omniai-ollama'
require_relative 'extensions/omniai-localai'

require_relative 'ai_client/configuration'
require_relative 'ai_client/middleware'
require_relative 'ai_client/version'

# Create a generic client instance using only model name
#   client = AiClient.new('gpt-3.5-turbo')
#
# Add middlewares
#   AiClient.use(RetryMiddleware.new(max_retries: 5, base_delay: 2, max_delay: 30))
#   AiClient.use(LoggingMiddleware.new(AiClient.configuration.logger))
#


class AiClient

  attr_reader :client,        # OmniAI's client instance
              :provider,      # [Symbol]
              :model,         # [String]
              :model_type,    # [Symbol]
              :logger, 
              :last_response,
              :timeout,
              :config         # Instance configuration

  # You can over-ride the class config by providing a block like this
  #   c = AiClient.new(...) do |config|
  #         config.logger = nil
  #       end
  #
  # You can also load an instance's config from a YAML file.
  #   c = AiClient.new('model_name'. cpmfog: 'path/to/file.yml', ...)
  #
  # ... and you can do both = load from a file and
  #     over-ride with a config block
  #
  # The options object is basically those things that the
  # OmniAI clients want to see.
  #
  def initialize(model, **options, &block)
    # Assign the instance variable @config from the class variable @@config
    @config = self.class.class_config.dup  
    
    # Yield the @config to a block if given
    yield(@config) if block_given?

    # Merge in an instance-specific YAML file
    if options.has_key?(:config)
      @config.merge! Config.load(options[:config])
      options.delete(:config) # Lconfig not supported by OmniAI
    end

    @model            = model
    explicit_provider = options.fetch(:provider, config.provider)

    @provider   = validate_provider(explicit_provider) || determine_provider(model)
    @model_type = determine_model_type(model)

    provider_config = @config.providers[@provider] || {}

    @logger   = options[:logger]    || @config.logger
    @timeout  = options[:timeout]   || @config.timeout
    @base_url = options[:base_url]  || provider_config[:base_url]
    @options  = options.merge(provider_config)

    # @client is an instance of an OmniAI::* class
    @client         = create_client

    @last_response  = nil
  end



  def response  = last_response
  def raw?      = config.return_raw
  
  def raw=(value)
    config.return_raw = value
  end



  ######################################
  def chat(messages, **params)
    result = call_with_middlewares(:chat_without_middlewares, messages, **params)
    @last_response = result
    raw? ? result : content
  end


  def chat_without_middlewares(messages, **params)
    @client.chat(messages, model: @model, **params)
  end

  ######################################
  def transcribe(audio, format: nil, **params)
    call_with_middlewares(:transcribe_without_middlewares, audio, format: format, **params)
  end

  def transcribe_without_middlewares(audio, format: nil, **params)
    @client.transcribe(audio, model: @model, format: format, **params)
  end

  ######################################
  def speak(text, **params)
    call_with_middlewares(:speak_without_middlewares, text, **params)
  end

  def speak_without_middlewares(text, **params)
    @client.speak(text, model: @model, **params)
  end


  ######################################
  def embed(input, **params)
    @client.embed(input, model: @model, **params)
  end

  def batch_embed(inputs, batch_size: 100, **params)
    inputs.each_slice(batch_size).flat_map do |batch|
      sleep 1 # DEBUG rate limits being exceeded
      embed(batch, **params)
    end
  end

  ######################################
  ## Utilities
  
  def content
    case @provider
    when :openai, :localai, :ollama
      last_response.data.dig('choices', 0, 'message', 'content')
    when :anthropic
      last_response.data.dig('content',0,'text')
    when :google
      last_response.data.dig('candidates', 0, 'content', 'parts', 0, 'text')
    when :mistral
      last_response.data.dig('choices', 0, 'message', 'content')
    else
      raise NotImplementedError, "Content extraction not implemented for provider: #{@provider}"
    end
  end
  alias_method :text, :content

  ##############################################
  ## Public Class Methods

  def method_missing(method_name, *args, &block)
    if @client.respond_to?(method_name)
      result = @client.send(method_name, *args, &block)
      @last_response = result if result.is_a?(OmniAI::Response)
      result
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    @client.respond_to?(method_name) || super
  end


  ##############################################
  private

  def validate_provider(provider)
    return nil if provider.nil?

    valid_providers = config.provider_patterns.keys
    unless valid_providers.include?(provider)
      raise ArgumentError, "Unsupported provider: #{provider}"
    end

    provider
  end


  def create_client
    api_key = fetch_api_key  # Fetching the API key should only happen for valid providers
    client_options = {
      api_key:  api_key,
      logger:   @logger,
      timeout:  @timeout
    }
    client_options[:base_url] = @base_url if @base_url
    client_options.merge!(@options).delete(:provider)

    case provider
    when :openai
      OmniAI::OpenAI::Client.new(**client_options)
    when :anthropic
      OmniAI::Anthropic::Client.new(**client_options)
    when :google
      OmniAI::Google::Client.new(**client_options)
    when :mistral
      OmniAI::Mistral::Client.new(**client_options)
    when :ollama
      OmniAI::Ollama::Client.new(**client_options)
    when :localai
      OmniAI::LocalAI::Client.new(**client_options)
    else
      raise ArgumentError, "Unsupported provider: #{@provider}"
    end
  end


  def fetch_api_key
    env_var_name = "#{@provider.upcase}_API_KEY"
    api_key = ENV[env_var_name]

    if api_key.nil? || api_key.empty?
      unless [:localai, :ollama].include? provider
        raise ArgumentError, "API key not found in environment variable #{env_var_name}"
      end
    end

    api_key
  end


  def determine_provider(model)
    config.provider_patterns.find { |provider, pattern| model.match?(pattern) }&.first ||
      raise(ArgumentError, "Unsupported model: #{model}")
  end


  def determine_model_type(model)
    config.model_types.find { |type, pattern| model.match?(pattern) }&.first ||
      raise(ArgumentError, "Unable to determine model type for: #{model}")
  end
end


