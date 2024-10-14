#!/usr/bin/env ruby
# examples/tools.rb
#
# Uses the AiClient::Function class to encapsulate the
# tools used as callback functions when specified in a
# chat prompt.


require_relative 'common'

AI = AiClient.new('gpt-4o')

box "Random Weather (temperature) Example"
title "Uses two named parameters to the callback function"

# Example subclass implementation
class WeatherFunction < AiClient::Function
  def self.call(location:, unit: 'Celsius')
    "#{rand(20..50)}° #{unit} in #{location}"
  end

  # Encapsulates registration details for the function
  def self.details
    # SMELL:  reconcile regester_tool and details
    {
      name:         'weather', # Must be a String
      description:  "Lookup the weather in a location",
      parameters:   AiClient::Tool::Parameters.new(
        properties: {
          location: AiClient::Tool::Property.string(description: 'e.g. Toronto'),
          unit:     AiClient::Tool::Property.string(enum: %w[Celsius Fahrenheit]),
        },
        required: [:location]
      )
    }
  end
end

# Register the tool for MyFunction
WeatherFunction.register

simple_prompt = <<~TEXT
  What is the weather in "London" in Celsius and "Paris" in Fahrenheit?
  Also what are some ideas for activities in both cities given the weather?
TEXT

response = AI.chat(
                    simple_prompt, 
                    tools: ['weather'] # must match the details[:name] value
                  )

puts response


##########################################
box "Accessing a database to get information"
title "Uses one named parameter to the callback function"

class LLMDetailedFunction < AiClient::Function
  def self.call(model_name:)
    records = AiClient::LLM.where(id: /#{model_name}/i)&.first
    records.inspect
  end

  def self.details
    {
      name:         'llm_db',
      description:  'lookup details about an LLM model name',
      parameters:   AiClient::Tool::Parameters.new(
        properties: {
          model_name: AiClient::Tool::Property.string
        },
        required: %i[model_name]
      )
    }  
  end
end

# Registering the LLM detail function
LLMDetailedFunction.register

simple_prompt = <<~PROMPT
  Get the details on an LLM model named 'bison' from the models database 
  of #{AiClient::LLM.count} models. Format the details for the model
  using markdown.  Format pricing information in terms of number of
  tokens per US dollar.
PROMPT

response = AI.chat(simple_prompt, tools: ['llm_db'])
puts response



##########################################

box "Using a function class and multiple tools"
title "Callback function has no parameters; but uses two functions"

class PerfectDateFunction < AiClient::Function
  def self.call
    "April 25th, it's not too hot nor too cold."
  end

  def self.details
    {
      name:         'perfect_date',
      description:  'what is the perfect date'
    }
  end
end

# Registering the perfect date function
PerfectDateFunction.register

response = AI.chat("what is the perfect date for current weather in Paris?", 
                   tools: %w[weather perfect_date])
puts response
puts

debug_me{[
  #'AiClient::Function.registry',
  'AiClient::Function.functions'
]}
