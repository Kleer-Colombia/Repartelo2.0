# Etapa 1: Construcción de activos JavaScript
FROM node:14.17.6 AS build-assets
WORKDIR /app

# Copia los archivos necesarios para instalar dependencias y compilar los activos
COPY package.json yarn.lock ./
RUN yarn install

COPY . ./

FROM ruby:2.6.7
WORKDIR /app

RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  npm \
  postgresql-client

# Instala Yarn
RUN npm install -g yarn@1.22.19

RUN gem install bundler:2.3.25

# Copia el Gemfile y Gemfile.lock, e instala dependencias de Ruby
COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test

# Copia el código de la aplicación y los activos compilados
COPY . ./
COPY --from=build-assets /app/public/packs public/packs

# Configura SECRET_KEY_BASE
ENV SECRET_KEY_BASE=dummy_secret_key

# Precompila activos adicionales de Rails
RUN RAILS_ENV=production SECRET_KEY_BASE=$SECRET_KEY_BASE bundle exec rails assets:precompile
# Expone el puerto de la aplicación
EXPOSE 3000

# Comando para iniciar el servidor
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
