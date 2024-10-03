# ai_client/logger_middleware.rb

class AiClient

  # logger = Logger.new(STDOUT)
  #
  # AiClient.use(
  #   AiClient::LoggingMiddleware.new(logger)
  # )
  #
  # Or, if you want to use the same logger as the AiClient:
  # AiClient.use(
  #   AiClient::LoggingMiddleware.new(
  #     AiClient.configuration.logger
  #   )
  # )

  class LoggingMiddleware
    def initialize(logger)
      @logger = logger
    end

    def call(client, next_middleware, *args)
      method_name = args.first.is_a?(Symbol) ? args.first : 'unknown method'
      @logger.info("Starting #{method_name} call")
      start_time = Time.now

      result = next_middleware.call(*args)

      end_time = Time.now
      duration = end_time - start_time
      @logger.info("Finished #{method_name} call (took #{duration.round(3)} seconds)")

      result
    end
  end
end
