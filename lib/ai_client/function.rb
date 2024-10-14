# lib/ai_client/function.rb

class AiClient

  # The Function class serves as a base class for creating functions
  # that can be registered and managed within the AiClient.
  #
  # Subclasses must implement the `call` and `details` methods
  # to define their specific behavior and properties.
  #
  class Function
    @@registry = {} # key is known by name (from details) and value is the AiClient::Tool

    class << self

      # Calls the function with the provided parameters.
      #
      # @param params [Hash] Named parameters required by the function.
      # @raise [NotImplementedError] if not implemented in the subclass.
      #
      def call(**params)
        raise NotImplementedError, "You must implement the call method"
      end

      # Provides the details about the function including its metadata.
      #
      # @return [Hash] Metadata containing details about the function.
      # @raise [NotImplementedError] if not implemented in the subclass.
      #
      def details
        raise NotImplementedError, "You must implement the details method"
      end


      # Registers a tool with the specified properties and parameters.
      #
      # This method creates an instance of AiClient::Tool with the
      # function class and its details and adds it to the registry.
      #
      def register
        this_tool = AiClient::Tool.new(
                      self, # This is the sub-class
                      **details
                    )

        registry[known_by] = this_tool
      end
      alias_method :enable, :register


      # Disables the function by removing its name from the registry.
      #
      # @return [void]
      #
      def disable
        registry.delete(known_by)
      end


      # Returns a list of enabled functions.
      #
      # @return [Array<Symbol>] Sorted list of function names.
      #
      def functions
        registry.keys.sort
      end


      # Returns the registry of currently registered functions.
      # This method is private to limit access to the registry's state.
      #
      # @return [Hash] The registry of registered functions.
      #
      def registry
        @@registry
      end


      # Returns the name under which the function is known.
      #
      # @return [Symbol] The symbol representation of the function's name.
      #
      def known_by
        details[:name]
      end


      private

      # Converts the class name to a symbol (e.g., MyFunction -> :my_function).
      #
      # @return [Symbol] The function name derived from the class name.
      #
      def function_name
        name.split('::').last.gsub(/([a-z])([A-Z])/, '\1_\2').downcase
      end
    end
  end
end

