FROM --platform=amd64 ruby:3.2.2

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && apt-get update \
  && curl -fsSL https://deb.nodesource.com/setup_14.x | bash \
  && apt-get install -y nodejs npm cron \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir /ez_web

RUN npm install --global yarn

WORKDIR /ez_web
COPY Gemfile /ez_web/Gemfile

COPY Gemfile.lock /ez_web/Gemfile.lock

RUN bundle install

COPY . /ez_web

COPY entrypoint.sh /usr/bin/

RUN chmod +x /usr/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]

# # syntax = docker/dockerfile:1

# # Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
# ARG RUBY_VERSION=3.2.2
# FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

# # Rails app lives here
# WORKDIR /rails

# # Set production environment
# ENV RAILS_ENV="production" \
#     BUNDLE_DEPLOYMENT="1" \
#     BUNDLE_PATH="/usr/local/bundle" \
#     BUNDLE_WITHOUT="development"


# # Throw-away build stage to reduce size of final image
# FROM base as build

# # Install packages needed to build gems and node modules
# RUN apt-get update -qq && \
#     apt-get install --no-install-recommends -y build-essential curl default-libmysqlclient-dev git libvips node-gyp pkg-config python-is-python3

# # Install JavaScript dependencies
# ARG NODE_VERSION=18.19.0
# ARG YARN_VERSION=1.22.21
# ENV PATH=/usr/local/node/bin:$PATH
# RUN curl -sL https://github.com/nodenv/node-build/archive/master.tar.gz | tar xz -C /tmp/ && \
#     /tmp/node-build-master/bin/node-build "${NODE_VERSION}" /usr/local/node && \
#     npm install -g yarn@$YARN_VERSION && \
#     rm -rf /tmp/node-build-master

# # Install application gems
# COPY Gemfile Gemfile.lock ./
# RUN bundle install && \
#     rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
#     bundle exec bootsnap precompile --gemfile

# # Install node modules
# COPY package.json yarn.lock ./
# RUN yarn install --frozen-lockfile

# # Copy application code
# COPY . .

# # Precompile bootsnap code for faster boot times
# RUN bundle exec bootsnap precompile app/ lib/

# # Precompiling assets for production without requiring secret RAILS_MASTER_KEY
# RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile


# # Final stage for app image
# FROM base

# # Install packages needed for deployment
# RUN apt-get update -qq && \
#     apt-get install --no-install-recommends -y curl default-mysql-client libvips && \
#     rm -rf /var/lib/apt/lists /var/cache/apt/archives

# # Copy built artifacts: gems, application
# COPY --from=build /usr/local/bundle /usr/local/bundle
# COPY --from=build /rails /rails

# # Run and own only the runtime files as a non-root user for security
# RUN useradd rails --create-home --shell /bin/bash && \
#     chown -R rails:rails db log storage tmp
# USER rails:rails

# # Entrypoint prepares the database.
# ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# # Start the server by default, this can be overwritten at runtime
# EXPOSE 3000
# CMD ["./bin/rails", "server"]
