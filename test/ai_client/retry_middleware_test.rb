# test/ai_client/retry_middleware_test.rb

require_relative '../test_helper'

class RetryMiddlewareTest < Minitest::Test
  def setup
    @middleware = AiClient::RetryMiddleware.new(
      max_retries: 2,
      base_delay: 0.1,
      max_delay: 0.2
    )
    @client = mock()
    @client.stubs(:logger).returns(Logger.new(nil))
  end

  def test_successful_call
    next_middleware = -> { "success" }
    result = @middleware.call(@client, next_middleware)
    assert_equal "success", result
  end

  def test_retry_on_rate_limit
    attempts = 0
    next_middleware = -> { 
      attempts += 1
      raise OmniAI::RateLimitError.new("Rate limit exceeded") if attempts == 1
      "success"
    }

    result = @middleware.call(@client, next_middleware)
    assert_equal "success", result
    assert_equal 2, attempts
  end

  def test_retry_on_network_error
    attempts = 0
    next_middleware = -> { 
      attempts += 1
      if attempts <= 2
        error = OmniAI::NetworkError.new("Network error")
        error.set_backtrace(caller)
        raise error
      end
      "success"
    }

    # Ensure we hit max retries before success
    @middleware = AiClient::RetryMiddleware.new(
      max_retries: 1,
      base_delay: 0.1,
      max_delay: 0.2
    )

    error = assert_raises(OmniAI::NetworkError) do
      @middleware.call(@client, next_middleware)
    end
    assert_equal "Network error", error.message
  end
end
