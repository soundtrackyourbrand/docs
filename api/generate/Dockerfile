FROM ruby:3.0.3-alpine3.15

RUN apk update && \
	apk upgrade --no-cache && \
	apk add --no-cache \
	build-base \
	nodejs \
	yarn \
	rsync

WORKDIR /src
COPY Gemfile .
COPY Gemfile.lock .

RUN gem install bundler:1.17.1
RUN gem install ffi:1.9.25
RUN bundle install
RUN yarn global add @2fd/graphdoc

COPY . /src/

CMD [ "/bin/sh", "./generate.sh" ]
