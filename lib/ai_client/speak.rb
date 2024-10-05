# lib/ai_client/speak.rb

class AiClient

  ######################################
  # OmniAI Params
  #   input   [String] required
  #   model   [String] required
  #   voice   [String] required
  #   speed   [Float] optional
  #   format  [String] optional (default "aac")
  #     aac mp3 flac opus pcm wav
  #
  # @yield [output] optional
  #
  # @return [Tempfile``]

  def speak(text, **params)
    call_with_middlewares(:speak_without_middlewares, text, **params)
  end

  def speak_without_middlewares(text, **params)
    @client.speak(text, model: @model, **params)
  end

end
