# lib/ai_client/llm.rb

require 'active_hash'

class AiClient

  # TODO: Think about this for the OpenRouter modesl DB
  #       Might cahnge this to ActiveYaml

  class LLM < ActiveHash::Base
    self.data = AiClient.models

    def model     = id.split('/')[1]
    def provider  = id.split('/')[0]

    class << self
      def import(path_to_uml_file) # TODO: load
        raise "TODO: Not Implemented: #{path_to_yml_file}"
      end

      def export(path_to_uml_file) # TODO: Dump
        raise "TODO: Not Implemented: #{path_to_yml_file}"
      end
    end
  end
end
