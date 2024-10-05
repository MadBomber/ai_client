# lib/ai_client/transcribe.rb

class AiClient

  ######################################
  # OmniAI Params
  #   model    [String]
  #   language [String, nil] optional
  #   prompt   [String, nil] optional
  #   format   [Symbol] :text, :srt, :vtt, or :json (default)
  #   temperature [Float, nil] optional

  def transcribe(audio, format: nil, **params)
    call_with_middlewares(:transcribe_without_middlewares, audio, format: format, **params)
  end

  def transcribe_without_middlewares(audio, format: nil, **params)
    @client.transcribe(audio, model: @model, format: format, **params)
  end

end
