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

require 'open_router'

require_relative 'ai_client/version'

require_relative 'ai_client/chat'
require_relative 'ai_client/embed'
require_relative 'ai_client/speak'
require_relative 'ai_client/transcribe'

require_relative 'ai_client/configuration'
require_relative 'ai_client/middleware'

require_relative 'ai_client/open_router_extensions'
require_relative 'ai_client/llm' # SMELL: must come after the open router stuff
require_relative 'ai_client/tool'
require_relative 'ai_client/function'

# Create a generic client instance using only model name
#   client = AiClient.new('gpt-3.5-turbo')
#
# Add middlewares
#   AiClient.use(RetryMiddleware.new(max_retries: 5, base_delay: 2, max_delay: 30))
#   AiClient.use(LoggingMiddleware.new(AiClient.configuration.logger))
#

class AiClient

  # Define the refinement for Hash
  module HashRefinement
    refine Hash do
      def tunnel(target_key)
        queue = [self] # Initialize the queue with the current hash

        until queue.empty?
          current = queue.shift # Dequeue the front hash

          # Check if the current hash contains the target key
          return current[target_key] if current.key?(target_key)

          # Enqueue sub-hashes and arrays to the queue for further searching
          current.each_value do |value|
            case value
            when Hash
              queue << value
            when Array
              queue.concat(value.select { |v| v.is_a?(Hash) }) # Add sub-hashes from the array
            end
          end
        end

        nil # Return nil if the key is not found
      end
    end
  end

  using HashRefinement

  attr_reader :client,        # OmniAI's client instance
              :provider,      # [Symbol]
              :model,         # [String]
              :logger, 
              :last_response,
              :timeout,
              :config         # Instance configuration

  # Initializes a new AiClient instance.
  #
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
  # @param model [String] The model name to use for the client.
  # @param options [Hash] Optional named parameters:
  #   - :provider [Symbol] Specify the provider.
  #   - :config [String] Path to a YAML configuration file.
  #   - :logger [Logger] Logger instance for the client.
  #   - :timeout [Integer] Timeout value for requests.
  # @yield [config] An optional block to configure the instance.
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

    provider_config = @config.providers[@provider] || {}

    @logger   = options[:logger]    || @config.logger
    @timeout  = options[:timeout]   || @config.timeout
    @base_url = options[:base_url]  || provider_config[:base_url]
    @options  = options.merge(provider_config)

    # @client is an instance of an OmniAI::* class
    @client         = create_client

    @last_response  = nil
  end

  # TODO: Review these raw-ish methods are they really needed?
  #       raw? should be a private method ??

  # Returns the last response received from the client.
  #
  # @return [OmniAI::Response] The last response.
  #
  def response  = last_response
  
  # Checks if the client is set to return raw responses.
  #
  # @return [Boolean] True if raw responses are to be returned.
  def raw?      = config.return_raw
  

  # Sets whether to return raw responses.
  #
  # @param value [Boolean] The value to set for raw responses return.
  #
  def raw=(value)
    config.return_raw = value
  end

  # Extracts the content from the last response based on the provider.
  #
  # @return [String] The extracted content.
  # @raise [NotImplementedError] If content extraction is not implemented for the provider.
  #
  def content
    case @provider
    when :localai, :mistral, :ollama, :open_router, :openai
      last_response.data.tunnel 'content'
      
    when :anthropic, :google
      last_response.data.tunnel 'text'

    else
      raise NotImplementedError, "Content extraction not implemented for provider: #{@provider}"
    end
  end
  alias_method :text, :content

  # Handles calls to methods that are missing on the AiClient instance.
  #
  # @param method_name [Symbol] The name of the method called.
  # @param args [Array] Arguments passed to the method.
  # @param block [Proc] Optional block associated with the method call.
  # @return [Object] The result from the underlying client or raises NoMethodError.
  #
  def method_missing(method_name, *args, &block)
    if @client.respond_to?(method_name)
      result = @client.send(method_name, *args, &block)
      @last_response = result if result.is_a?(OmniAI::Response)
      result
    else
      super
    end
  end

  # Checks if the instance responds to the missing method.
  #
  # @param method_name [Symbol] The name of the method to check.
  # @param include_private [Boolean] Whether to include private methods in the check.
  # @return [Boolean] True if the method is supported by the client, false otherwise.
  #
  def respond_to_missing?(method_name, include_private = false)
    @client.respond_to?(method_name) || super
  end


  ##############################################
  private

  # Validates the specified provider.
  #
  # @param provider [Symbol] The provider to validate.
  # @return [Symbol, nil] Returns the validated provider or nil.
  # @raise [ArgumentError] If the provider is unsupported.
  #
  def validate_provider(provider)
    return nil if provider.nil?

    valid_providers = config.provider_patterns.keys
    unless valid_providers.include?(provider)
      raise ArgumentError, "Unsupported provider: #{provider}"
    end

    provider
  end

  # Creates an instance of the appropriate OmniAI client based on the provider.
  #
  # @return [OmniAI::Client] An instance of the configured OmniAI client.
  # @raise [ArgumentError] If the provider is unsupported.
  #
  def create_client
    client_options = {
      api_key:  fetch_api_key,
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
      OmniAI::OpenAI::Client.new(host: 'http://localhost:11434', api_key: nil, **client_options)

    when :localai
      OmniAI::OpenAI::Client.new(host: 'http://localhost:8080', api_key: nil, **client_options)

    when :open_router
      OmniAI::OpenAI::Client.new(host: 'https://openrouter.ai', api_prefix: 'api', **client_options)

    else
      raise ArgumentError, "Unsupported provider: #{@provider}"
    end
  end


  # Similar to fetch_access_token but for the instance config
  #
  # @return [String, nil] The retrieved API key or nil if not found.
  #
  def fetch_api_key
    config.envar_api_key_names[@provider]
      &.map { |key| ENV[key] }
      &.compact
      &.first
  end

  # Determines the provider based on the provided model.
  #
  # @param model [String] The model name.
  # @return [Symbol] The corresponding provider.
  # @raise [ArgumentError] If the model is unsupported.
  #
  def determine_provider(model)
    config.provider_patterns.find { |provider, pattern| model.match?(pattern) }&.first ||
      raise(ArgumentError, "Unsupported model: #{model}")
  end
end


