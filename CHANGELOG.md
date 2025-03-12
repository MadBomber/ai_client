## [Unreleased]

## Released

### [0.4.5] - 2025-03-02
- Added ability to obtain a list of available models from an Ollama server.
- Added `ollama_model_exists?` method to check if a specific model is available on an Ollama server.
- Added command-line utility `bin/list_ollama_models` to display available Ollama models.
- Added support for configuring custom Ollama hosts via the providers configuration.

### [0.4.4] - 2025-03-02
- Added ability to obtain a list of available models from an Ollama server.
- Added `ollama_model_exists?` method to check if a specific model is available on an Ollama server.
- Added command-line utility `bin/list_ollama_models` to display available Ollama models.
- Added support for configuring custom Ollama hosts via the providers configuration.

### [0.4.3] - 2025-01-05
- updated models.yml file with latest dump from open_router

### [0.4.2] - 2025-01-05
- updated models.yml file with latest dump from open_router
- noted some SMELLS w/r/t ollama processing from a host that is not localhost
- updzted test cases for new open_router model dump
- increasing test coverage
- tweaking stuff

### [0.4.1] - 2024-10-21
- fixed the context problem.  the chatbot method works now.

### [0.4.0] - 2024-10-20
- Removed Logger.new(STDOUT) from the default configuration
  > config.logger now returns nil  If you want a class or instance logger setup, then you will have to do a config.logger = Logger.new(STDOUT) or whatever you need.
- Adding basic @context for chat-bots
- Added `context_length` to configuration as the number of responses to remember as context
- Added a default model for each major provider; using "auto" for open_router.ai
- Added a default provider (OpenAI)
  > AiClient.new() will use the config.default_provider and that provider's default_model
- Fixed problem with advanced block-based prompt construction for chat

### [0.3.1] - 2024-10-19
- updated the open_routed_extensions file
- added simplecov to see code coverage
- updated README with options doc

### [0.3.0] - 2024-10-13
- Breaking Change
- Added new class AiClient::Function to encapsulate the callback functions used as tools in chats.
- Updated the examples/tools.rb file to use the new function class

### [0.2.5] - 2024-10-11
- Added examples/tools.rb to demonstrate use of function callbacks to provide information to the LLM when it needs it.

### [0.2.4] - 2024-10-10
- constrained gem omniai-openai to version 1.8.3+ for access to open_router.ai
- caching models database from open_router.ai
- added class methods reset_default_config and reset_llm_data
- support for open_router.ai should be fully integrated now that omniai-openai is at version 1.8.3


### [0.2.3] - 2024-10-08
- refactored the OmniAI extensions for Ollama, LocalAI and OpenRouter
- added a file for OpenRouter extensions
- Added the LLM class

### [0.2.2] - 2024-10-07
- Added support for open_router.ai with extensions/omniai-open_router.rb
- Removed the `model_type` object
- Added ability to dump a config to a YAML file

### [0.2.1] - 2024-10-05
- Added support for YAML configuration files

### [0.2.0] - 2024-10-04
- Configuration is more robust.  Still room for improvement.

### [0.1.0] - 2024-10-02

- Initial working release
