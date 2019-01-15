#!/usr/bin/env bash

# build api docs from /generate/source
bundle exec middleman build --clean
rsync -a build/* ../
rm -rf build

if [ $? -eq 0 ]; then
    echo [x] API docs
    echo [ ] API reference
else
    echo Something went wrong when building the API docs. Please check error message and try again.
fi

# build reference from /generate/reference
graphdoc -c reference/package.json --force

if [ $? -eq 0 ]; then
    echo [x] API docs
    echo [x] API reference
    echo All done, commit and push back into repo. It will publish automagically.
else
    echo Something went wrong when building the API reference. Please check error message and try again.
fi
