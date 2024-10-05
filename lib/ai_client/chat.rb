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
    result = call_with_middlewares(:chat_without_middlewares, messages, **params)
    @last_response = result
    raw? ? result : content
  end


  def chat_without_middlewares(messages, **params)
    @client.chat(messages, model: @model, **params)
  end

end
