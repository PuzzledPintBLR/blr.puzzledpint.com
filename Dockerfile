FROM ruby:3.3-slim

# Install system dependencies needed for native gems
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      build-essential \
      git && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Cache gem installation
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy application source code
COPY . .

EXPOSE 4000 35729

CMD ["bundle", "exec", "jekyll", "serve", "--host", "0.0.0.0", "--port", "4000", "--livereload"]
