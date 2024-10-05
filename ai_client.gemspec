# frozen_string_literal: true

require_relative "lib/ai_client/version"

Gem::Specification.new do |spec|
  spec.name     = "ai_client"
  spec.version  = AiClient::VERSION
  spec.authors  = ["Dewayne VanHoozer"]
  spec.email    = ["dvanhoozer@gmail.com"]

  spec.summary      = "A generic AI Client for many providers"
  spec.description  = <<~TEXT
    `ai_client` is a versatile Ruby gem that serves as a generic client 
    for interacting with various AI service providers through a unified 
    API. Designed to simplify the integration of large language models 
    (LLMs) into applications, `ai_client` allows developers to create 
    instances using just the model name, greatly reducing configuration 
    overhead. With built-in support for popular AI providers—including 
    OpenAI, Anthropic, Google, Mistral, LocalAI and Ollama—the gem abstracts the 
    complexities of API interactions, offering methods for tasks such 
    as chatting, transcription, speech synthesis, and embedding. The 
    middleware architecture enables customizable processing of requests 
    and responses, making it easy to implement features like logging and 
    retry logic. Seamlessly integrated with the `OmniAI` framework, 
    `ai_client` empowers developers to leverage cutting-edge AI capabilities 
    without vendor lock-in, making it an essential tool for modern AI-driven 
    applications.
  TEXT

  spec.homepage     = "https://github.com/MadBomber/ai_client"
  spec.license      = "MIT"

  spec.required_ruby_version = ">= 3.0.0"

  # Specify the gem server as rubygems.org
  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  # Populate metadata with appropriate URLs
  spec.metadata["homepage_uri"]     = spec.homepage
  spec.metadata["source_code_uri"]  = "https://github.com/MadBomber/ai_client"
  spec.metadata["changelog_uri"]    = "https://github.com/MadBomber/ai_client/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end

  spec.require_paths  = ["lib"]

  spec.add_dependency "hashie"
  spec.add_dependency "omniai"
  spec.add_dependency "omniai-anthropic"
  spec.add_dependency "omniai-google"
  spec.add_dependency "omniai-mistral"
  spec.add_dependency "omniai-openai"

  spec.add_development_dependency "amazing_print"
  spec.add_development_dependency "debug_me"
  spec.add_development_dependency "hashdiff"
  spec.add_development_dependency "mocha"


end
