# nerdgeschoss Development Environment

This project contains all dependencies and services required by other nerdgeschoss projects. To run all needed versions of PostgreSQL, MySQL, and other databases, run

    docker-compose up

# Setting up a Rails Application

Here we will go over how to setup rails for the first time on your machine.

We will mostly follow Rails [Getting Started Guide](https://guides.rubyonrails.org/getting_started.html) with some changes.

## rbenv

First thing we need is a version manager for Ruby. We use rbenv at nerdgeschoss.

    brew install rbenv

You can check your ruby version by typing this in your project folder:

    ruby --version

If a version is not installed, you can add it by `rbenv install x.x.x`.

## Rails

Now let’s install Rails.

    gem install rails

Steps 3, 4 and 5 can be done in parallel.

## bundle

Now we need to install the dependencies, for that we use `bundler` (newer versions of ruby already have this preinstalled).

If this is your first time setting up a rails project you will need to install it.

    gem install bundle

Then you will need to run this to install the ruby dependencies.

    bundle install

### MySQL Troubleshooting

During the bundle install you may face an error with mysql, in that case just follow the instructions on the error.

To install MySQL:

    brew install mysql

If `bundle install` fails with `ld: library not found for -lzstd`, follow the instructions of [this post](https://stackoverflow.com/a/67877734).

Alternatively, try:

```bash
ls -la $(which mysql)
```

That gives you where the `mysql` binary is, something like `/usr/local/bin/mysql -> ../Cellar/mysql/8.0.28/bin/mysql`,
meaning that your `mysql` install is in `/usr/local/Cellar/mysql/8.0.28`.

Use that path for the next command.

```bash
gem install mysql2 -v '0.5.3' -- \
 --with-mysql-lib=/usr/local/Cellar/mysql/8.0.28/lib \
 --with-mysql-dir=/usr/local/Cellar/mysql/8.0.28 \
 --with-mysql-config=/usr/local/Cellar/mysql/8.0.28/bin/mysql_config \
 --with-mysql-include=/usr/local/Cellar/mysql/8.0.28/include
```

### PostgreSQL (PSQL) Troubleshooting

If `bundle install` fails for the GEM `pg`, install `postgresql`:

    brew install postgresql

## docker-compose

Now to setup we development environment we use `docker-compose`.

    docker-compose up

## yarn

Now to install the Javascript dependencies we use `yarn`.

To install it:

    npm install -g yarn

To resolve dependencies of a project:

    yarn

## Database

Now let’s setup up the database.

First we create the database.

    rails db:create

Then we will run the migrations to update the database to the latest schema.

    rails db:migrate

Then we will seed our database with fake data for testing.

    rake db:seed

If you are interested in finding out what is going on behind the scenes (because it’s doing a lot and you will feel like the process just hanged) you can use `tail log/development.log` to hook into and view the log file.

## Rails Server

Now that we have everything setup we can finally start the server.

    rails s

The default app port is `3000`, so if you navigate to [localhost:3000](https://localhost:3000) you should see a page (depending on the project).

## guard

With the above setup we will see our code changes when we refresh the page, but to make our development life easier we will also do the following.

Run `guard` to watch for changed files, reload our website on change and re-run tests if the file had a corresponding spec.

    guard

Run a `webpack` dev server to make our javascript updates faster.

    bin/webpack-dev-server

With that in place you can start developing.

# Feature Specific Installations:

## imagemagick

If the project deals with images, you will need to install the `imagemagick` native Mac libarary.

    brew install imagemagick

# Creating a new Rails App

Use the supplied application generator:

```bash
rails new YOUR_APP_NAME --database=postgresql --skip-jbuilder --skip-test --javascript=esbuild --skip-bundle --force --template=https://raw.githubusercontent.com/nerdgeschoss/development-environment/main/rails-template.rb
```
