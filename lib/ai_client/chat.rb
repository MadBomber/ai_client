# lib/ai_client/chat.rb

class AiClient

  ######################################
  # OmniAI Params
  #   model:        @model    [String] optional
  #   format:       @format   [Symbol] optional :text or :json
  #   stream:       @stream   [Proc, nil] optional
  #   tools:        @tools    [Array<OmniAI::Tool>] optional
  #   temperature:  @temperature  [Float, nil] optional
  #
  # Initiates a chat session.
  #
  # @param messages [Array<String>] the messages to send.
  # @param params [Hash] optional parameters.
  # @option params [Array<OmniAI::Tool>] :tools an array of tools to use.
  # @return [String] the result from the chat.
  #
  # @raise [RuntimeError] if tools parameter is invalid.
  #
  def chat(messages='', **params, &block)    
    if params.has_key? :tools
      tools = params[:tools]
      if tools.is_a? Array
        tools.map!{|function_name| AiClient::Function.registry[function_name]}
      elsif true == tools
        tools = AiClient::Function.registry.values
      else
        raise 'what is this'
      end
      params[:tools] = tools
    end

    @last_messages  = messages
    messages        = add_context(messages)
    result          = call_with_middlewares(
                        :chat_without_middlewares, 
                        messages, 
                        **params,
                        &block
                      )
    @last_response  = result
    result          = raw? ? result : content

    @context.push(@last_response)

    result
  end


  # Adds context to the current prompt.
  #
  # @param prompt [String, Array<String>] the current prompt.
  # @return [String, Array<String>] the prompt with context added.
  #
  def add_context(prompt)
    return(prompt)  if  @config.context_length.nil? || 
                        0 == @config.context_length ||
                        prompt.is_a?(Array)         || 
                        @context.empty?


    prompt << "\nUse the following context in crafting your response.\n"

    @context[..config.context_length].each do |result|
      prompt << "You previously responded with:\n"
      prompt << "#{raw? ? result.inspect : content(result)}"
    end

    prompt
  end


  # Clears the current context.
  #
  # @return [void]
  #
  def clear_context
    @context = []
  end


  # Chats with the client without middleware processing.
  #
  # @param messages [Array<String>] the messages to send.
  # @param params [Hash] optional parameters.
  # @return [String] the result from the chat.
  #
  def chat_without_middlewares(messages, **params, &block)
    @client.chat(messages, model: @model, **params, &block)
  end
end
