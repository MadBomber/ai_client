# lib/ai_client/tool.rb

# TODO: Turn this into a Function class using the pattern
#       in examples/tools.rb
#       put the function names as symbols into a class Array
#       In the AiClient class transform the tools: []
#       parameter from an Array of Symbols into an Array
#       of FUnction instances.

class AiClient::Tool < OmniAI::Tool
  
  def xyzzy = self.class.xyzzy

  class << self
    def xyzzy = puts "Magic"
  end
end

