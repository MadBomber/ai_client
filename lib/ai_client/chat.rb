# lib/ai_client/chat.rb

class AiClient

  ######################################
  # OmniAI Params
  #   model:        @model    [String] optional
  #   format:       @format   [Symbol] optional :text or :json
  #   stream:       @stream   [Proc, nil] optional
  #   tools:        @tools    [Array<OmniAI::Tool>] optional
  #   temperature:  @temperature  [Float, nil] optional

  def chat(messages, **params)    
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

    result = call_with_middlewares(:chat_without_middlewares, messages, **params)
    @last_response = result
    raw? ? result : content
  end


  def chat_without_middlewares(messages, **params)
    @client.chat(messages, model: @model, **params)
  end

end
