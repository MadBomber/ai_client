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
    
    # Initializes the LoggingMiddleware with a logger.
    #
    # @param logger [Logger] The logger used for logging middleware actions.
    #
    def initialize(logger)
      @logger = logger
    end

    # Calls the next middleware in the stack while logging the start and finish times.
    #
    # @param client [Object] The client instance.
    # @param next_middleware [Proc] The next middleware to call.
    # @param args [Array] The arguments passed to the middleware call, with the first being the method name.
    #
    # @return [Object] The result of the next middleware call.
    #
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
