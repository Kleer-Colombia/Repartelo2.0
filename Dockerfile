# Imagen base para Rails
FROM ruby:2.7.7 AS rails-app
WORKDIR /app

# Instala dependencias del sistema necesarias para Rails y PostgreSQL
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  curl \
  postgresql-client \
  dos2unix

# Instala Node.js 14.17.6 y npm
# Instala Node.js (inicialmente) y npm
RUN apt-get install -y nodejs npm

# Instala `n` para gestionar versiones de Node.js
RUN npm install -g n && n 14.17.6

# Verifica la versión de Node.js y npm
RUN node -v && npm -v

# Instala Yarn y Bundler
RUN npm install -g yarn@1.22.19
RUN gem install bundler:2.3.25

# Copia Gemfile y Gemfile.lock, e instala dependencias de Ruby
COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test

# Copia package.json y yarn.lock, instala dependencias de Node.js
COPY package.json yarn.lock ./
RUN yarn install

# Copia todo el código de la aplicación
COPY . ./

# Convierte los finales de línea a LF
RUN find . -type f -exec dos2unix {} +

# Compila activos frontend y precompila los activos de Rails
ENV SECRET_KEY_BASE=dummy_secret_key
RUN RAILS_ENV=production NODE_ENV=production bundle exec rails assets:precompile

# Expone el puerto de la aplicación
EXPOSE 3000

# Comando para iniciar el servidor Rails
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
