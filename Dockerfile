# Start with an official Ubuntu image
FROM ubuntu:20.04

# Set non-interactive mode for apt-get to avoid prompts
ENV DEBIAN_FRONTEND=noninteractive

# Update the package list and install required dependencies
RUN apt-get update && apt-get install -y \
  curl \
  gnupg2 \
  lsb-release \
  build-essential \
  libssl-dev \
  libreadline-dev \
  zlib1g-dev \
  libyaml-dev \
  libsqlite3-dev \
  sqlite3 \
  git \
  libcurl4-openssl-dev \
  libffi-dev \
  libgdbm6 libgdbm-dev \
  libncurses5-dev \
  automake \
  libtool \
  bison \
  libssl-dev \
  libyaml-dev \
  libreadline6-dev \
  libffi-dev \
  wget \
  ca-certificates \
  apt-transport-https \
  libgmp-dev \
  && rm -rf /var/lib/apt/lists/*

# Install Node.js (Using NodeSource repository for the latest LTS version)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
  && apt-get install -y nodejs

# Install Ruby 3.3.5 (manually from the source)
RUN curl -fsSL https://cache.ruby-lang.org/pub/ruby/3.3/ruby-3.3.5.tar.gz -o ruby-3.3.5.tar.gz \
  && tar -xzvf ruby-3.3.5.tar.gz \
  && cd ruby-3.3.5 \
  && ./configure \
  && make \
  && make install \
  && rm -rf ruby-3.3.5 ruby-3.3.5.tar.gz

# PostgreSQL development libraries required for the pg gem
RUN apt-get install -y libpq-dev

# Verify installation of Node.js and Ruby
RUN node -v && ruby -v

RUN corepack enable

# Set the working directory in the container
WORKDIR /app

# Copy Gemfile and install Ruby dependencies
COPY Gemfile* ./
RUN bundle install

# Install npm dependencies (if applicable)
COPY package.json yarn.lock ./
RUN yarn install

# Install any required Ruby gems (modify this line if you have a Gemfile)
RUN gem install bundler
RUN bundle install

# Install tzdata for time zone support
RUN apt-get update && apt-get install -y tzdata

# Add the service label
LABEL service=print-lab

# Expose the application port (modify this as needed)
EXPOSE 3000:3000
EXPOSE 5432:5432

# Copy the rest of your application code
COPY . .

RUN yarn build

RUN RAILS_ENV=production rails db:migrate

# Set the default command to run the Rails server
CMD ["rails", "s", "-b", "0.0.0.0", "-e", "production", "-p", "3000"]

# Build the Docker image
# 
# docker buildx build --platform linux/amd64 -t andriano606/print-lab:latest .
# docker push andriano606/print-lab:latest
# docker pull andriano606/print-lab:latest
# docker run --platform=linux/amd64 -d -e RAILS_MASTER_KEY=<rails master key> -p 3000:3000 andriano606/print-lab:latest
# docker exec -it <container name or id> bash
