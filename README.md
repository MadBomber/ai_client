# AiClient

First and foremost a big **THANK YOU** to [Kevin Sylvestre](https://ksylvest.com/) for his gem [OmniAI](https://github.com/ksylvest/omniai) upon which this effort depends.

**This is a work in progress**  Its implemented as a class rather than the typical module for most gems.  The `AiClient::Configuration` class is a little first draft-ish.  I'm looking to bulk it up a lot.  At this point I think some of the current tests are failing; but, over all `AiClien` is working.  I've used early versions of it in several projects.

## Summary

`ai_client` is a versatile Ruby gem that serves as a generic client for interacting with various AI service providers through a unified API provided by Kevin's gem `OmniAI`. The `AiClient` class is designed to simplify the integration of large language models (LLMs) into applications. `AiClient` allows developers to create instances using just the model name, greatly reducing configuration overhead.

With built-in support for popular AI providers—including OpenAI, Anthropic, Google, Mistral, LocalAI and Ollama—the gem abstracts the complexities of API interactions, offering methods for tasks such as chatting, transcription, speech synthesis, and embedding.

The middleware architecture enables customizable processing of requests and responses, making it easy to implement features like logging and retry logic. Seamlessly integrated with the `OmniAI` framework, `ai_client` empowers developers to leverage cutting-edge AI capabilities without vendor lock-in, making it an essential tool for modern AI-driven applications.

## Installation

If you are using a Gemfile and bundler in your project just install the gem by executing:

```bash
bundle add ai_client
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install ai_client
```

## Usage

Basic usage:

```ruby
AI = AiClient.new('gpt-4o')
```

That's it.  Just provide the model name that you want to use.  If you application is using more than one model, no worries, just create multiple AiClient instances.

```ruby
c1 = AiClient.new('nomic-embeddings-text')
c2 = AiClient.new('gpt-4o-mini')
```

### What Now?

TODO: Document the methods and their options.

```ruby
AI.chat(...)
AI.transcribe(...)
AI.speak(...)
AI.embed(...)
AI.batch_embed(...)
```

TODO: see the [examples] directory.

### System Environment Variables

The API keys used with each LLM provider have the pattern `XXX_API_KEY` where XXX is the name of the provided.  For example `OPENAI_API_KEY1` and `ANTROPIC_API_KEY` etc.

TODO: list all providers supported and their envar

### Options

TODO: document the options like `provider: :ollama`

## Contributing

I can sure use your help.  This industry is moving faster than I can keep up with.  If you have a bug fix or new feature idea then have at it.  Send me a pull request so we all can benefit from your efforts.

If you only have time to report a bug, that's fine.  Just create an issue in this repo.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
