# Reference | Soundtrack API
We use [graphdoc](https://github.com/2fd/graphdoc) to generate a reference for Soundtrack API. The reference is published on GitHub Pages ([find it here](https://soundtrackyourbrand.github.io/docs-soundtrack_api_reference/)).

If you're looking for the Soundtrack API documentation, [find it here](https://github.com/soundtrackyourbrand/docs-soundtrack_api).

## Requirements
You need a local version of graphdoc installed.
```bash
    npm install -g @2fd/graphdoc
```

## How to update and publish

```bash
    git clone git@github.com:soundtrackyourbrand/docs-soundtrack_api_reference.git
    
    cd docs-soundtrack_api_reference
    
    graphdoc --force
```

graphdoc makes an introspection query and auto-generates the reference.

Now push back the code to the repo. The GitHub page will be automatically updated (it publishes whatever is in the /docs folder).
