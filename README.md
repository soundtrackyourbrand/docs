# Overview
[This repo](https://github.com/soundtrackyourbrand/docs) contains:
* [Documentation for Soundtrack API](https://developer.soundtrackyourbrand.com/api)
* [Auto-generated reference for Soundtrack API](https://developer.soundtrackyourbrand.com/api/reference)
* [Documentation for Soundtrack SDK](https://developer.soundtrackyourbrand.com/sdk)

# Feedback/suggestions
* For Soundtrack API: make pull requests of [this file](https://github.com/soundtrackyourbrand/docs/blob/master/api/generate/source/index.html.md)
* For Soundtrack SDK: make pull requests of [this file](https://github.com/soundtrackyourbrand/docs/blob/master/sdk/index.md)

# Questions
[Join our public Slack channel](https://join.slack.com/t/soundtrack-api/shared_invite/enQtNjM5MzAwMzExNTI3LTg0ODY3NzViNzIzNjRmOWZiODc4YjQ4ZTZmYzA2MzRiNWIwMmYyNjRhMDdjNjdlMmYwNzk0NzM3OTdkZWRhZTQ).

# Kudos
Thanks to [Slate](https://github.com/lord/slate) & [GraphDoc](https://github.com/2fd/graphdoc).

# Making updates
**Soundtrack employees only**
1. Review pull request. Pull requests are only allowed on these two files: [API](https://github.com/soundtrackyourbrand/docs/blob/master/api/generate/source/index.html.md) & [SDK](https://github.com/soundtrackyourbrand/docs/blob/master/sdk/index.md).
2. Head to `docs/api/generate/` to generate docs
    - Install prerequisites: node, ruby (`>2.3.1`) & bundler.
    - Install dependencies `bundle install`
    - Install graphdoc `yarn global add @2fd/graphdoc`
    - Generate docs `./generate.sh` 
3. Commit and push back into repo. The pages will be updated automagically.
