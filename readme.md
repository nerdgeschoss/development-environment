# nerdgeschoss Development Environment

This project contains all dependencies and services required by other nerdgeschoss projects. To run all needed versions of PostgreSQL, MySQL, and other databases, run

```bash
docker-compose up
```

# Setting up a Rails Application
Here we will go over how to setup rails for the first time on your machine.

we will mostly follow Rails Getting Started Guide with some changes.
https://guides.rubyonrails.org/getting_started.html


1. First thing we need is the “Ruby Version Manager”, `rvm` is setting the Ruby version to the version defined in the `Gemfile`, this curl command will install it.
    \curl -sSL https://get.rvm.io | bash

you can check your ruby version by typing this in your project folder:

    which ruby

 `rvm` will automatically check that so you don’t have to, if you want to know more about rvm visit rvm.io
 

2.  Now let’s install Rails
    gem install rails

Steps 3, 4 and 5 can be done in parallel.


3. Now we need to install the dependencies, for that we use `bundle`

if this is your first time setting up a rails project you will need to install it :-

    gem install bundle

then you will need to run this to install the ruby dependencies

    bundle install

during the bundle install you may face an error with mysql,  in that case just follow the instructions on the error to install MySQL `brew install mysql`.


4. Now to setup we development environment we use `docker-compose` :
    docker-compose up


5. Now to install the Javascript dependencies we use `yarn`
    yarn


6. Now let’s setup up the database:-
    1. First we create the database
    rails db:create
    b. Then we will run the migrations to update the database to the latest schema
    rails db:migrate
    c. Then we will seed our database with fake data for testing
    rake db:seed

if you are interested in finding out what is going on behind the scenes (because it’s doing a lot and you will feel like the process just hanged) you can use `tail log/development.log` to hook into and view the log file.


7. Now that we have everything setup we can finally start the server
    rails s

default app port is 3000, so if you navigate to `localhost:3000` you should see a page (depending on the project)


8. With the above setup we will see our code changes when we refresh the page, but to make our development life easier we will also do the following:
    1. run `guard` to watch for changed files, reload our website on change and re-run tests if the file had a corresponding spec
    guard
    b. run a `webpack` dev server to make our javascript updates faster
    bin/webpack-dev-server

with that in place you can start developing.


Feature Specific Installations:
1. imagemagick:-
    if the project deals with images, you will need to install the imagemagick native mac libarary
    brew install imagemagick

