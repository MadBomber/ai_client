# ai_client/retry_middleware.rb

class AiClient

  # AiClient.use(
  #   AiClient::RetryMiddleware.new(
  #     max_retries:  5,
  #     base_delay:   2,
  #     max_delay:    30
  #   )
  # )
  #
  class RetryMiddleware

    # Initializes a new instance of RetryMiddleware.
    #
    # @param max_retries [Integer] The maximum number of retries to attempt (default: 3).
    # @param base_delay [Integer] The base delay in seconds before retrying (default: 2).
    # @param max_delay [Integer] The maximum delay in seconds between retries (default: 16).
    #
    def initialize(max_retries: 3, base_delay: 2, max_delay: 16)
      @max_retries  = max_retries
      @base_delay   = base_delay
      @max_delay    = max_delay
    end

    # Calls the next middleware, retrying on specific errors.
    #
    # @param client [AiClient] The client instance that invokes the middleware.
    # @param next_middleware [Proc] The next middleware in the chain to call.
    # @param args [Array] Any additional arguments to pass to the next middleware.
    #
    # @raise [StandardError] Reraise the error if max retries are exceeded.
    #
    def call(client, next_middleware, *args)
      retries = 0
      begin
        next_middleware.call
      rescue OmniAI::RateLimitError, OmniAI::NetworkError => e
        if retries < @max_retries
          retries += 1
          delay = [@base_delay * (2 ** (retries - 1)), @max_delay].min
          client.logger.warn("Retrying in #{delay} seconds due to error: #{e.message}")
          sleep(delay)
          retry
        else
          raise
        end
      end
    end
  end
end
