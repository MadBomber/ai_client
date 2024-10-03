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
    def initialize(max_retries: 3, base_delay: 2, max_delay: 16)
      @max_retries  = max_retries
      @base_delay   = base_delay
      @max_delay    = max_delay
    end

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
