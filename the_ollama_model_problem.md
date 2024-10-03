## The Ollama Model Problem

The ability ot a model-centric configuration where the provider is derived from the model break with those models that can be run locally as well as be accessed through an off-platform provider API.  Take for example the `mistral` model family which can be access to the `La Platform` API or downloaded locally and used with `Ollama`.

If I specify `mistral-large` I should also in the constructor method also provide a `provider:` parameter to specify where that model is going to be accessed.
