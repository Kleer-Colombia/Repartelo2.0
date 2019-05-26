# README

* ## Ruby version
    2.5.1
    
* ## System dependencies
    * Docker 
    * Yarn
    * Postgres

* ## Configuration
        
  ### for standalone config
        - install  and configure Db postgres
        - bundle install
        - bundle exec bin/setup
        - bundle exec rails db:create
        - bundle exec rails db:migrate
                
    para instalar dependencias de package.json
    
        yarn install
        
    para windows:
        
        - gem uninstall bcrypt
        - gem uninstall bcrypt-ruby
        - gem install bcrypt --platform=ruby

    iniciar la base de datos
        
        bundle exec rails db:create
        bundle exec rails db:migrate

  ### for docker environment
     
    open carefully read and edit the `.env` file
    
    run:
    
        docker-compose up
        docker-compose up --build
    
    If is necessary:    
        
        docker-compose run repartelo rake db:create
        docker-compose run repartelo rake db:migrate
        
    visit 
     
        Running Docker natively? http://localhost:4000
    
    Stop the app
    
         docker-compose down
         
    Rebuild the application
     
     If you make changes to the Gemfile or the Compose file to try out some different
      configurations, you need to rebuild. Some changes require only
       `docker-compose up --build`, but a full rebuild requires a re-run of
        `docker-compose run web bundle install` to sync changes in the `Gemfile.lock`
         to the host, followed by `docker-compose up --build.`
        
     more reference on: https://docs.docker.com/compose/rails/#stop-the-application
      

* ## How to run the test suite
    
    ### for standalone execution:
    
    - remember install ghekodriver and put it on PATH
    
    start app in test mode:
   
        rails s -e test
       
    start front app:
            
        ruby ./bin/webpack-dev-server
       
    run cucumber:
    
        rails cucumber 
     
        rails cucumber FEATURE=features/login.feature
     
    Optinal you can choose headless chrome
        
        rails cucumber BROWSER=headless-chrome
        
    to run rspec:
    
        bundle exec rspec
        
     ### Runing acceptance test with docker and selenium grid:
     
    start docker environment
     
        docker-compose up
    
    run the test with:
        
        rails cucumber RAILS_ENV='acceptance_test' REPARTELO_HOME='http://repartelo:3000/#/login'
        
    or, for a specific scenario:
    
         rails cucumber FEATURE=features/calculateBalance.feature:7 RAILS_ENV='acceptance_test' REPARTELO_HOME='http://repartelo:3000/#/login'   
                 
    **make sure that the DB config be the same in `.env` and `config/database.yml``**
 


* ## Deployment instructions (Production)

    - **push to Heroku and run migrations.**
    
    - to care the DB:
    
    backup db:
        
        heroku pg:backups:schedule DATABASE_URL --at '02:00 America/Los_Angeles' --app repartelo2
        
    to Restore:
    
        heroku pg:backups:restore 'https://www.dropbox.com/s/pbvjknn85j11ku6/repartelo20180513.backup' DATABASE_URL -a repartelo2
        
    or
        
        heroku pg:psql < db/repartelo20180513.backup
        
    on local machine:
        
        pg_restore --verbose --clean --no-acl --no-owner -h localhost -d repartelo2_0_development production.dump

* more info on:

    https://mkdev.me/en/posts/rails-5-vue-js-how-to-stop-worrying-and-love-the-frontend
    
    to migrate the DB on heroku:
    
        heroku run rails --trace db:migrate
        
        


