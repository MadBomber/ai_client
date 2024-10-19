# lib/ai_client/middleware.rb

# TODO: As currently designed the middleware must
#       be set before an instance of AiClient is created.
#       Any `use` commands for middleware made after
#       the instance is created will not be available
#       to that instance.
#       Change this so that middleware can be added
#       and removed from an existing client.

# AiClient class that handles middleware functionality
# for API calls.
class AiClient

  # Calls the specified method with middlewares applied.
  #
  # @param method [Symbol] the name of the method to be called
  # @param args [Array] additional arguments for the method
  # @param kwargs [Hash] named parameters for the method
  # @param block [Proc] optional block to be passed to the method
  #
  # @return [Object] result of the method call after applying middlewares
  #
  def call_with_middlewares(method, *args, **kwargs, &block)
    stack = self.class.middlewares.reverse.reduce(-> { send(method, *args, **kwargs, &block) }) do |next_middleware, middleware|
      -> { middleware.call(self, next_middleware, *args, **kwargs) }
    end
    stack.call
  end


  class << self

    # Returns the list of middlewares applied to the client.
    #
    # @return [Array] list of middlewares
    #
    def middlewares
      @middlewares ||= []
    end

    # Adds a middleware to the stack.
    #
    # @param middleware [Proc] the middleware to be added
    #
    # @return [void]
    #
    def use(middleware)
      middlewares << middleware
    end

    # Clears all middlewares from the client.
    #
    # @return [void]
    #
    def clear_middlewares
      @middlewares = []
    end
  end
end
