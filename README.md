# README

* ### Ruby version
    2.5.1
    
* ### System dependencies
    Docker for db
    Yarn

* ### Configuration
    
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

* ### Database creation
    bundle exec rails db:create
    bundle exec rails db:migrate


* ### Database initialization

* How to run the test suite
    
    - remember install ghekodriver and put it on PATH
    
    start app in test mode:
   
        rails s -e test
       
    start front app:
            
        ruby ./bin/webpack-dev-server
       
    run cucumber:
    
        rails cucumber
        rails cucumber FEATURE=features/login.feature

* ### Services (job queues, cache servers, search engines, etc.)

* ### Deployment instructions
    
    backup db:
        
        heroku pg:backups:schedule DATABASE_URL --at '02:00 America/Los_Angeles' --app repartelo2
        
    to Restore:
    
        heroku pg:backups:restore 'https://www.dropbox.com/s/pbvjknn85j11ku6/repartelo20180513.backup' DATABASE_URL -a repartelo2
        
        or
        
        heroku pg:psql < db/repartelo20180513.backup

* more info on:

    https://mkdev.me/en/posts/rails-5-vue-js-how-to-stop-worrying-and-love-the-frontend
