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
RUN curl -s --retry 3 -L https://heroku-buildpack-ruby.s3.amazonaws.com/cedar-14/ruby-2.2.2-jruby-9.0.0.0.tgz | tar xz -C /app/.jruby
ENV PATH /app/.jruby/bin:$PATH

# Install Bundler
RUN jruby -S gem install bundler -v 1.9.7 --no-ri --no-rdoc

# Run bundler to cache dependencies
ONBUILD COPY ["Gemfile", "Gemfile.lock", "*.gemspec", "/app/user/"]
ONBUILD RUN bundle install

# How to conditionally `rake assets:precompile`?

ONBUILD COPY . /app/user/
