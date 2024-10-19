# lib/ai_client/tool.rb

class AiClient::Tool < OmniAI::Tool
  
  # TODO: Is there any additional functionality that
  #       needs to be added to the Rool class that would
  #       be helpful?
  
  def xyzzy = self.class.xyzzy

  class << self
    def xyzzy = puts "Magic"
  end
end

