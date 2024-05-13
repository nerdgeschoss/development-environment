# nerdgeschoss Development Environment

This project contains all dependencies and services required by other nerdgeschoss projects. To run all needed versions of PostgreSQL, MySQL, and other databases, run

    docker compose up

### Auto-Start Mode

To have the environment start automatically when _Docker_ starts, execute the following command once.

    docker compose up -d

This starts them in _detached mode_ which makes them run in the background and start (and re-start on failure) automatically.

This is useful in a scenario where you don't want to have a terminal tab dedicated to it and you can then, after starting _Docker_, skip the whole _starting the environment manually_ step.

When the content of the `docker-compose.yml` file change, you need to run the command again for _Docker_ to pick up the modifications and run the latest versions and configurations available.

# Setting up a Rails Application

Here we will go over how to setup rails for the first time on your machine.

We will mostly follow Rails [Getting Started Guide](https://guides.rubyonrails.org/getting_started.html) with some changes.

## Manage versions of languages and runtime environment

You can use `asdf` to manage multiple tools. Check out the [guide](https://asdf-vm.com/guide/getting-started.html) for more, or use distinct managers as described below.

### rbenv

`rbenv` is a version manager for Ruby.

    brew install rbenv

You can check your ruby version by typing this in your project folder:

    ruby --version

If a version is not installed, you can add it by `rbenv install x.x.x`.

### node

Make sure you have node installed. Use volta as your version manager, follow the steps as decribed in the [docs](https://docs.volta.sh/guide/).

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

Or for short just

    bundle

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

## yarn

Now to install the Javascript dependencies we use `yarn`.

To install it:

    npm install -g yarn

To resolve dependencies of a project:

    yarn

## Database

Now let’s setup up the database.

For most projects there should be a setup script available.

    bin/setup

If that does not work, follow these steps:

First we create the database.

    rails db:create

Then we will run the migrations to update the database to the latest schema.

    rails db:migrate

Then we will seed our database with fake data for testing.

    rake db:seed

If you are interested in finding out what is going on behind the scenes (because it’s doing a lot and you will feel like the process just hanged) you can use `tail log/development.log` to hook into and view the log file.

## Start the application

Now that we have everything setup, we can start by running

    bin/dev

This sets up everything you need such as a rails server, a background worker and a second server for the frontend if needed.
You can connect to the a session in a new terminal tab with

    overmind c web

for the server, and

    overmind c worker

for the background worker.

In the background there are these processes running:

### Rails Server

This is how to manually start the server.

    rails s

The default app port is `3000`, so if you navigate to [localhost:3000](https://localhost:3000) you should see a page (depending on the project).

### Sidekiq

We use sidekiq for background jobs. If you start the server manually use a new terminal tab to run:

    sidekiq

### frontend

Please refer to the readme of the specific project for information.
In most cases the default port for the frontend will be `8080` ([localhost:8080](https://localhost:8080)).

## guard

With the above setup we will see our code changes when we refresh the page, but to make our development life easier we will also do the following.

Run `guard` to watch for changed files, reload our website on change and re-run tests if the file had a corresponding spec.

    guard

# Feature Specific Installations:

## imagemagick

If the project deals with images, you will need to install the `imagemagick` native Mac libarary.

    brew install imagemagick

# Creating a new Rails App

Use the supplied application generator:

```bash
rails new YOUR_APP_NAME --database=postgresql --skip-jbuilder --skip-test --javascript=esbuild --skip-bundle --force --template=https://raw.githubusercontent.com/nerdgeschoss/development-environment/main/rails-template.rb
```
