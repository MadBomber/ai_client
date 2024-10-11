#!/usr/bin/env ruby
# examples/tools.rb
# See: https://ksylvest.com/posts/2024-08-16/using-omniai-to-leverage-tools-with-llms

require 'debug_me'
include DebugMe

require_relative '../lib/ai_client'

AI = AiClient.new('gpt-4o')

my_weather_function = Proc.new do |location:, unit: 'Celsius'| 
  "#{rand(20..50)}° #{unit} in #{location}"
end

weather = AiClient::Tool.new(
  my_weather_function,
  name: 'weather',
  description: 'Lookup the weather in a location',
  parameters: AiClient::Tool::Parameters.new(
    properties: {
      location: AiClient::Tool::Property.string(description: 'e.g. Toronto'),
      unit: AiClient::Tool::Property.string(enum: %w[Celsius Fahrenheit]),
    },
    required: %i[location]
  )
)

simple_prompt = <<~TEXT
  What is the weather in "London" in Celsius and "Paris" in Fahrenheit?
  Also what are some ideas for activities in both cities given the weather?
TEXT

response = AI.chat(simple_prompt, tools: [weather])
print "\n\n"
puts response

##########################################

llm_db_function = Proc.new do |params|
  records = AiClient::LLM.where(id: /#{params[:model_name]}/i)
  records.inspect
end


llm_db = AiClient::Tool.new(
  llm_db_function,
  name: 'llm_db',
  description: 'lookup details about an LLM model name',
  parameters: AiClient::Tool::Parameters.new(
    properties: {
      model_name: AiClient::Tool::Property.string
    },
    required: %i[model_name]
  )
)

response = AI.chat("Get details on an LLM model named bison.  Which one is the cheapest per prompt token.", tools: [llm_db])
print "\n\n"
puts response

##########################################

# TODO: Look at creating a better function
#       process such that the tools parameter
#       is an Array of Symbols which is
#       maintained as a class variable.
#       The symboles are looked up and the
#       proper instance is inserted in its
#       place.

class FunctionClass
  def self.call
    "April 25th its not to hot nor too cold."
  end

  def function(my_name)
    AiClient::Tool.new(
      self.class, # with a self.call method
      name: my_name,
      description: 'what is the perfect date'
    )
  end
end

perfect_date = FunctionClass.new.function('perfect_date')

response = AI.chat("what is the perfect date for paris weather?", tools: [weather, perfect_date])
print "\n\n"
puts response
