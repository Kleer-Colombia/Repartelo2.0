# README

* Ruby version
    2.3
* System dependencies
    Docker for db
    Yarn

* Configuration
    
        docker-compose up
        docker-compose start
    
        bundle install
        bundle exec rails db:create
        bundle exec rails db:migrate
        bundle exec bin/setup
        
        bin/rails webpacker:install
        bin/rails webpacker:install:vue
        
    para instalar dependencias de package.json
    
        bin/yarn install
        
    for windows:
        
        - gem uninstall bcrypt
        - gem uninstall bcrypt-ruby
        - gem install bcrypt --platform=ruby

* Database creation
    bundle exec rails db:create
    bundle exec rails db:migrate


* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions
    
    backup db:
        
        heroku pg:backups:schedule DATABASE_URL --at '02:00 America/Los_Angeles' --app repartelo2
        
    to Restore:
    
        heroku pg:backups:restore 'https://www.dropbox.com/s/pbvjknn85j11ku6/repartelo20180513.backup' DATABASE_URL -a repartelo2
        
        or
        
        heroku pg:psql < db/repartelo20180513.backup

* ...


https://mkdev.me/en/posts/rails-5-vue-js-how-to-stop-worrying-and-love-the-frontend


parar prod en heroku:

    bundle exec puma -t 5:5 -p ${PORT:-3000} -e ${RACK_ENV:-production}