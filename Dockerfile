FROM ruby:2.6.7

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev

RUN curl -sL https://deb.nodesource.com/setup_7.x | bash - \
&& apt-get install -y nodejs

RUN apt-get install -y curl apt-transport-https wget && \
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
apt-get update && apt-get install -y yarn

RUN mkdir /app
WORKDIR /app

RUN gem update --system
RUN gem install bundler -v 2.0.1

COPY Gemfile Gemfile.lock ./
COPY .gemrc ~/
RUN bundle install

COPY . .

RUN apt-get install yarn

LABEL maintainer="Santiago Herrera <santiago.herrera@kleer.la>"

CMD puma -C config/puma.rb