# Inherit from Heroku's stack
FROM heroku/cedar:14

RUN mkdir -p /app/user
WORKDIR /app/user

ENV STACK "cedar-14"
ENV HOME /app

# Install the JDK
RUN mkdir -p /app/.jdk
ENV JAVA_HOME /app/.jdk
RUN curl -s --retry 3 -L https://lang-jvm.s3.amazonaws.com/jdk/cedar-14/openjdk1.8-latest.tar.gz | tar xz -C /app/.jdk
ENV PATH /app/.jdk/bin:$PATH

# Install JRuby
RUN mkdir -p /app/.jruby
ENV JRUBY_HOME /app/.jruby
RUN curl -s --retry 3 -L https://heroku-buildpack-ruby.s3.amazonaws.com/cedar-14/ruby-2.2.2-jruby-9.0.3.0.tgz | tar xz -C /app/.jruby
ENV PATH /app/.jruby/bin:$PATH

# Install Node.js
ENV NODE_ENGINE 0.12.2
RUN mkdir -p /app/heroku/node
RUN curl -s https://s3pository.heroku.com/node/v$NODE_ENGINE/node-v$NODE_ENGINE-linux-x64.tar.gz | tar --strip-components=1 -xz -C /app/heroku/node
ENV PATH /app/heroku/node/bin::$PATH

# Install Bundler
RUN jruby -S gem install bundler -v 1.9.7 --no-ri --no-rdoc
ENV PATH /app/user/bin:/app/heroku/ruby/bundle/ruby/2.2.0/bin:$PATH
ENV BUNDLE_APP_CONFIG /app/heroku/ruby/.bundle/config

# Run bundler to cache dependencies
ONBUILD COPY ["Gemfile", "Gemfile.lock", "/app/user/"]
ONBUILD RUN jruby -S bundle install --path /app/heroku/ruby/bundle --jobs 4
ONBUILD ADD . /app/user

ONBUILD ENV RACK_ENV production
ONBUILD ENV SECRET_KEY_BASE $(openssl rand -base64 32)
