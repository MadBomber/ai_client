# lib/ai_client/middleware.rb

# TODO: As concurrently designed the middleware must
#       be set before an instance of AiClient is created.
#       Any `use` commands for middleware made after
#       the instance is created will not be available
#       to that instance.
#       Change this so that middleware can be added
#       and removed from an existing client.


class AiClient

  def call_with_middlewares(method, *args, **kwargs, &block)
    stack = self.class.middlewares.reverse.reduce(-> { send(method, *args, **kwargs, &block) }) do |next_middleware, middleware|
      -> { middleware.call(self, next_middleware, *args, **kwargs) }
    end
    stack.call
  end


  class << self

    def middlewares
      @middlewares ||= []
    end

    def use(middleware)
      middlewares << middleware
    end

    def clear_middlewares
      @middlewares = []
    end
  end

end
