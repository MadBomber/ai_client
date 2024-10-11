# lib/ai_client/function.rb

class AiClient
  class Function
    # Class instance variable to hold all enabled function names
    @functions = []

    class << self
      attr_reader :functions

      # Class method to call the function (to be implemented in subclasses)
      def call
        raise NotImplementedError, "You must implement the call method"
      end

      # Enable the function by adding its name to the functions array
      def enable
        function_name = underscore_name
        @functions << function_name unless @functions.include?(function_name)
      end

      # Disable the function by removing its name from the functions array
      def disable
        function_name = underscore_name
        @functions.delete(function_name)
      end

      # Register a tool with the specified properties and parameters
      def register_tool(name:, description:, parameters:)
        AiClient::Tool.new(
          method(:call), # Register the class method call as the tool
          name: name,
          description: description,
          parameters: parameters
        )
      end

      private

      # Converts the class name to a symbol (e.g., MyFunction -> :my_function)
      # Private method; only accessible within this class and subclasses
      def underscore_name
        name.split('::').last.gsub(/([a-z])([A-Z])/, '\1_\2').downcase.to_sym
      end
    end
  end
end

# Example subclass implementation
class MyFunction < AiClient::Function
  def self.call(location:, unit: 'Celsius')
    "#{rand(20..50)}° #{unit} in #{location}"
  end

  # Registering the tool for this function
  def self.register
    enable
    register_tool(
      name: underscore_name,
      description: "Lookup the weather in a location",
      parameters: AiClient::Tool::Parameters.new(
        properties: {
          location: AiClient::Tool::Property.string(description: 'e.g. Toronto'),
          unit: AiClient::Tool::Property.string(enum: %w[Celsius Fahrenheit]),
        },
        required: %i[location]
      )
    )
  end
end

# Register the tool for MyFunction
MyFunction.register

# Example usage
puts AiClient::Function.functions.inspect # Output: [:my_function]
