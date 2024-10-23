# lib/ai_client/retry_middleware.rb

class AiClient
  class RetryMiddleware
    def initialize(max_retries: 3, base_delay: 1, max_delay: 16)
      @max_retries  = max_retries
      @base_delay   = base_delay
      @max_delay    = max_delay
    end

    def call(client, next_middleware, *args)
      @retries  = 0
      @client   = client

      begin
        next_middleware.call
      rescue OmniAI::RateLimitError, OmniAI::NetworkError => e
        if @retries < @max_retries
          delay = retry_delay(e)
          log_retry(delay, e)
          sleep(delay)
          retry
        else
          raise
        end
      end
    end
    
    private

    def retry_delay(error)
      @retries += 1
      [@base_delay * (2 ** (@retries - 1)), @max_delay].min
    end

    def log_retry(delay, error)
      @client.logger.warn("Retrying in #{delay} seconds due to error: #{error.message}")
    end
  end
end
