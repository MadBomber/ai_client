# lib/ai_client/tool.rb

class AiClient::Tool < OmniAI::Tool
  
  def xyzzy = self.class.xyzzy

  class << self
    def xyzzy = puts "Magic"
  end
end

