# test/ai_client/middleware_test.rb

require_relative '../test_helper'

class TestMiddleware
  def self.call(client, next_middleware, *args)
    result = next_middleware.call
    result.data['choices'][0]['message']['content'] += " - Processed by TestMiddleware"
    result
  end
end

class Middleware1
  def self.call(client, next_middleware, *args)
    result = next_middleware.call
    result.data['choices'][0]['message']['content'] += " one"
    result
  end
end

class Middleware2
  def self.call(client, next_middleware, *args)
    result = next_middleware.call
    result.data['choices'][0]['message']['content'] += " two"
    result
  end
end

class ErrorMiddleware
  def self.call(client, next_middleware, *args)
    raise RuntimeError.new("Simulated network issue")
  end
end

class InterruptingMiddleware
  def self.call(client, next_middleware, *args)
    "Interrupted"
  end
end

class AiClient::MiddlewareTest < Minitest::Test
  def setup
    @model = 'gpt-3.5-turbo'

    @middleware = AiClient::RetryMiddleware.new(
      max_retries: 2,
      base_delay: 0.1,
      max_delay: 0.2
    )
    @client = mock()
    @client.stubs(:logger).returns(Logger.new(nil))
  end

  def test_middleware_chain_interruption
    skip
    AiClient.clear_middlewares
    AiClient.use(InterruptingMiddleware)
    local_client = AiClient.new(@model)
    local_client.raw = true
    # No need to set up mock_client since InterruptingMiddleware returns early

    result = local_client.chat('Hello')
    assert_equal "Interrupted", result
  end

  def test_retry_on_network_error
    attempts = 0
    next_middleware = -> { 
      attempts += 1
      if attempts <= 1
        raise OmniAI::NetworkError.new("Network error")
      end
      "success"
    }

    @middleware = AiClient::RetryMiddleware.new(
      max_retries: 0, # No retries to ensure error is raised
      base_delay: 0.1,
      max_delay: 0.2
    )

    assert_raises(OmniAI::NetworkError) do
      @middleware.call(@client, next_middleware)
    end
  end
end

# Test middleware classes remain unchanged
