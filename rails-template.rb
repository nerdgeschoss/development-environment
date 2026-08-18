run "rm app/views/layouts/*.erb"

file "Gemfile", <<~RUBY
  source "https://rubygems.org"
  ruby File.read(".ruby-version").strip

  # Core
  gem "rails", "7.1.2"
  gem "puma"

  # Database
  gem "pg"
  gem "redis"

  # Performance
  gem "oj"
  gem "bootsnap", require: false

  # Extensions
  gem "shimmer"
  gem "mini_magick"
  gem "dotenv-rails"
  gem "rails-i18n"
  gem "sidekiq"
  gem "sidekiq-scheduler"
  gem "kaminari"
  gem "groupdate"
  gem "bcrypt"
  gem "friendly_id"
  gem "countries", require: "countries/global"
  gem "document_serializable"
  gem "sitemap_generator"
  gem "image_processing"
  gem "slim-rails"
  gem "pundit"
  gem "yael"
  gem "translate_client"

  # Assets
  gem "jsbundling-rails"
  gem "stimulus-rails"
  gem "sassc-rails"
  gem "autoprefixer-rails"
  gem "turbo-rails"
  gem "serviceworker-rails"


  group :development, :test do
    gem "rspec-rails"
    gem "standard"
    gem "capybara"
    gem "cuprite"
    gem "i18n-tasks", "0.9.35"
    gem "rack_session_access"
  end

  group :development do
    gem "listen"
    gem "web-console"
    gem "annotate"
    gem "rb-fsevent"
    gem "letter_opener"
    gem "debug"
    gem "guard"
    gem "guard-rspec"
    gem "solargraph-standardrb"
  end
RUBY

initializer "config.rb", <<~RUBY
  Config = Shimmer::Config.instance
  Shimmer::Meta.app_name = "#{app_name}"
RUBY

file "config/database.yml", <<~YML
  default: &default
    adapter: postgresql
    encoding: unicode
    host: 127.0.0.1
    port: 54313
    pool: <%= ENV["DB_POOL"] || ENV["RAILS_MAX_THREADS"] || 5 %>
    username: <%= ENV["PG_USER"] || "postgres" %>
    variables:
      statement_timeout: <%= ENV["STATEMENT_TIMEOUT"] || 60000 %>

  development:
    <<: *default
    database: #{app_name}_development

  test:
    <<: *default
    database: #{app_name}_test

  production:
    <<: *default
YML

file "config/routes.rb", <<~RUBY
  # frozen_string_literal: true

  require "sidekiq/web"
  require "sidekiq-scheduler/web"

  Rails.application.routes.draw do
    mount ActionCable.server => "/cable"
    mount Sidekiq::Web => "/sidekiq" # move to admin once there is authentication
    get "sitemaps/*path", to: "shimmer/sitemaps#show"
    resources :files, only: :show, controller: "shimmer/files"

    scope "/(:locale)", locale: /#{I18n.available_locales.join("|")}/ do
      root "pages#home"
    end
  end
RUBY

file "config/application.rb", <<~RUBY
  require_relative "boot"

  require "rails"
  # Pick the frameworks you want:
  require "active_model/railtie"
  require "active_job/railtie"
  require "active_record/railtie"
  require "active_storage/engine"
  require "action_controller/railtie"
  require "action_mailer/railtie"
  require "action_mailbox/engine"
  require "action_text/engine"
  require "action_view/railtie"
  require "action_cable/engine"
  # require "rails/test_unit/railtie"

  # Require the gems listed in Gemfile, including any gems
  # you've limited to :test, :development, or :production.
  Bundler.require(*Rails.groups)

  module #{app_name.classify}
    class Application < Rails::Application
      # Initialize configuration defaults for originally generated Rails version.
      config.load_defaults 7.0
      config.time_zone = "Berlin"

      config.middleware.use Shimmer::CloudflareProxy

      config.action_mailer.default_url_options = {host: ENV["HOST"]} if ENV["HOST"].present?
      config.active_storage.variant_processor = :mini_magick

      config.assets.paths << Rails.root.join("node_modules")
      ActiveRecord::Tasks::DatabaseTasks.fixtures_path = Rails.root.join("spec/fixtures")
    end
  end
RUBY

file "config/storage.yml", <<~YML
  test:
    service: Disk
    root: <%= Rails.root.join("tmp/storage") %>

  local:
    service: Disk
    root: <%= Rails.root.join("storage") %>
  s3:
    service: S3
    access_key_id: <%= ENV["AWS_ACCESS_KEY_ID"] %>
    secret_access_key: <%= ENV["AWS_SECRET_ACCESS_KEY"] %>
    region: <%= ENV["AWS_REGION"] %>
    bucket: <%= ENV["AWS_BUCKET"] %>
YML

file ".solargraph.yml", <<~YML
  plugins:
    - solargraph-standardrb
  reporters:
    - standardrb
YML

file ".vscode/launch.json", <<~JSON
  {
    // Use IntelliSense to learn about possible attributes.
    // Hover to view descriptions of existing attributes.
    // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
    "version": "0.2.0",
    "configurations": [
      {
        "type": "rdbg",
        "name": "Rails Server",
        "request": "launch",
        "command": "bin/rails",
        "script": "server",
        "args": [],
        "askParameters": false,
        "useBundler": true
      }
    ]
  }
JSON

file ".vscode/settings.json", <<~JSON
  {
    "editor.formatOnSave": true,
    "typescript.tsdk": "node_modules/typescript/lib",
    "rubyTestExplorer.rspecCommand": "bin/rspec",
    "rubyTestExplorer.testFramework": "rspec"
  }
JSON

file ".browserlistrc", "defaults"

file ".editorconfig", <<~TOML
  ; EditorConfig is awesome: http://EditorConfig.org

  ; top-most EditorConfig file
  root = true

  ; Unix-style newlines with a newline ending every file
  [*]
  indent_style = spaces
  end_of_line = lf
  insert_final_newline = true
  trim_trailing_whitespace = true
  indent_size = 2
TOML

file ".env", <<~ENV
  REDIS_URL=redis://127.0.0.1:6379

  # ease development with this puma settings
  WEB_CONCURRENCY=0
  PUMA_WORKER_TIMEOUT=6000
  RAILS_MAX_THREADS=20
ENV

file ".prettierignore", "config/locales/*.yml"

file ".prettierrc", <<~JS
  {
    "singleQuote": true,
    "trailingComma": "es5"
  }
JS

file "app.json", <<~JS
  {
    "addons": ["newrelic", "heroku-postgresql", "heroku-redis"],
    "buildpacks": [
      {
        "url": "https://github.com/brandoncc/heroku-buildpack-vips.git"
      },
      {
        "url": "heroku/nodejs"
      },
      {
        "url": "heroku/ruby"
      }
    ],
    "env": {
      "SECRET_KEY_BASE": {
        "generator": "secret"
      }
    },
    "formation": {
      "web": {
        "quantity": 1,
        "worker": 1
      }
    },
    "name": "#{app_name}",
    "scripts": {
      "postdeploy": "pg_dump --clean --no-owner --no-acl $SOURCE_DATABASE_URL | psql $DATABASE_URL && bin/rails db:migrate"
    },
    "stack": "heroku-20"
  }
JS

file "Procfile", <<~PROC
  web: bundle exec puma -C config/puma.rb
  worker: bundle exec sidekiq -e production
  release: DB_POOL=2 bundle exec rake db:migrate_if_tables
PROC

file "Procfile.dev", <<~PROC
  web: bundle exec rails s -p ${PORT:-3000} -b 0.0.0.0
  worker: DB_POOL=3 bundle exec sidekiq
  js: yarn build --watch
  livereload: yarn live
PROC

file "bin/dev", <<~BASH
  #!/usr/bin/env bash

  if command -v overmind &> /dev/null
  then
    overmind s -f Procfile.dev -p ${PORT:-3000} -P 10
    exit
  fi

  if ! gem list --silent --installed foreman
  then
    echo "Installing foreman..."
    gem install foreman
  fi

  foreman start -f Procfile.dev "$@"
BASH

run "chmod +x bin/dev"

file "app/assets/fonts/.keep", ""

file "app/assets/config/manifest.js", <<~JS
  //= link_tree ../images
  //= link_tree ../fonts
  //= link_directory ../stylesheets .css
  //= link_tree ../builds
JS

file "config/sidekiq.yml", <<~YML
  :concurrency: 3
  :queues:
    - dispatch
    - default
    - mailers
    - low_priority
    - active_storage_analysis
    - active_storage_purge
YML

file "tsconfig.json", <<~JS
  {
    "compilerOptions": {
      "declaration": false,
      "emitDecoratorMetadata": true,
      "experimentalDecorators": true,
      "lib": ["ES2019", "dom"],
      "module": "es6",
      "moduleResolution": "node",
      "baseUrl": ".",
      "paths": {
        "*": ["node_modules/*", "app/javascript/*"]
      },
      "sourceMap": true,
      "target": "ES2017",
      "noEmit": true,
      "strict": true
    },
    "exclude": ["**/*.spec.ts", "node_modules", "vendor", "public"],
    "compileOnSave": false
  }
JS

file "package.json", <<~JS
  {
    "scripts": {
      "format": "prettier --write \\"src/**/*.{tsx,ts,scss,json}\\"",
      "lint": "yarn lint:types && yarn lint:style && yarn lint:format",
      "lint:types": "tsc --noEmit",
      "lint:style": "eslint app/javascript/**/*.ts --max-warnings 0",
      "lint:format": "prettier --list-different \\"app/**/*.{ts,scss,json}\\"",
      "build": "esbuild app/javascript/*.* --bundle --sourcemap --outdir=app/assets/builds",
      "bundle-size": "npx source-map-explorer app/assets/builds/application.js app/assets/builds/application.js.map --no-border-checks",
      "start": "yarn build --watch",
      "live": "yarn livereload -e scss app/assets"
    },
    "license": "MIT"
  }
JS

file "app/assets/builds/.keep", ""

file ".eslintrc.js", <<~JS
  module.exports = {
    env: {
      browser: true,
      es6: true,
    },
    ignorePatterns: ['node_modules/'],
    parser: '@typescript-eslint/parser',
    extends: [
      'plugin:@typescript-eslint/recommended',
      'plugin:prettier/recommended',
    ],
    parserOptions: {
      ecmaVersion: 2018,
      sourceType: 'module',
    },
    plugins: ['@typescript-eslint'],
    rules: {
      'no-console': 2,
      '@typescript-eslint/explicit-function-return-type': [
        'error',
        {
          allowExpressions: true,
        },
      ],
      eqeqeq: 2,
    },
    settings: {
      react: {
        version: 'detect', // Tells eslint-plugin-react to automatically detect the version of React to use
      },
    },
  };
JS

file "app/javascript/application.ts", <<~JS
  import '@hotwired/turbo-rails';
  import { start } from '@nerdgeschoss/shimmer';
  import { application } from 'controllers/application';
  import './controllers';

  start({ application });
JS

file "app/javascript/controllers/application.ts", <<~JS
  import { Application } from '@hotwired/stimulus';

  const application = Application.start();

  application.debug = false;

  export { application };
JS

file ".github/workflows/ci.yml", <<~YML
  name: CI

  on: [push]

  jobs:
    ruby:
      runs-on: ubuntu-20.04

      services:
        postgres:
          image: postgres:13
          env:
            POSTGRES_USER: postgres
            POSTGRES_PASSWORD: postgres
            POSTGRES_DB: app
          ports:
            - 5432:5432
          # needed because the postgres container does not provide a healthcheck
          options: --health-cmd pg_isready --health-interval 10s --health-timeout 5s --health-retries 5
        redis:
          image: redis:latest
          ports:
            - 6379:6379

      steps:
        - uses: actions/checkout@v2
        - uses: actions/setup-node@v2
          with:
            node-version: '16.x'
            cache: yarn
        - name: Install yarn
          run: yarn install
        - name: Set up Ruby
          uses: ruby/setup-ruby@v1
          with:
            bundler-cache: true
        - name: Lint
          run: bundle exec standardrb
        - name: Translations Lint
          run: bundle exec i18n-tasks health
        - name: JS Lint
          run: yarn lint
        - name: Build Assets
          run: yarn build
        - name: Create PG Database
          run: bundle exec rake db:create db:migrate
          env:
            DATABASE_URL: postgres://postgres:postgres@127.0.0.1:5432/app
            RAILS_ENV: test
        - name: Build and test with Rake
          run: bundle exec rspec --format documentation
          env:
            DATABASE_URL: postgres://postgres:postgres@127.0.0.1:5432/app
            REDIS_URL: redis://127.0.0.1:6379
            RAILS_ENV: test
YML

initializer "i18n.rb", <<~RUBY
  # frozen_string_literal: true

  disabled_locales = ENV["DISABLED_LOCALES"].to_s.split(",").map(&:downcase).map(&:to_sym)
  I18n.enforce_available_locales = true
  I18n.available_locales = [:en] - disabled_locales
  I18n.default_locale = I18n.available_locales.first

  Rails.application.configure do
    config.i18n.fallbacks = [:en] - disabled_locales
  end
RUBY

initializer "oj.rb", <<~RUBY
  # frozen_string_literal: true

  Oj.optimize_rails
RUBY

initializer "serviceworker.rb", <<~RUBY
  # frozen_string_literal: true

  Rails.application.configure do
    config.serviceworker.routes.draw do
      match "/serviceworker.js"
    end
  end
RUBY

initializer "uuid.rb", <<~RUBY
  # frozen_string_literal: true

  Rails.application.configure do
    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
    end
  end
RUBY

file "app/views/layouts/application.html.slim", <<~SLIM
  doctype html
  html lang=I18n.locale
    = render "components/head"
    body class=Rails.env
      = yield
SLIM

file "app/views/components/_head.html.slim", <<~SLIM
  head
    meta charset="UTF-8"

    / WebApp
    meta name="viewport" content="width=device-width, initial-scale = 1.0, viewport-fit=cover"
    / link rel="manifest" href=manifest_path
    / link rel="apple-touch-icon" href=asset_path("app-icon.png")
    meta name="theme-color" content="#1d2024"
    / SEO
    /= favicon_link_tag asset_path('favicon.svg')

    / Security
    = csrf_meta_tags
    = csp_meta_tag

    / Assets
    = stylesheet_link_tag "application", media: "all", "data-turbo-track": "reload"
    = javascript_include_tag "application", "data-turbo-track": "reload", defer: true

    = render_meta

    = yield :additional_head_tags if content_for? :additional_head_tags
SLIM

file "app/controllers/application_controller.rb", <<~RUBY
  # frozen_string_literal: true

  class ApplicationController < ActionController::Base
    include Shimmer::Localizable
    include Shimmer::RemoteNavigation

    before_action :check_locale
  end
RUBY

file "app/controllers/pages_controller.rb", <<~RUBY
  # frozen_string_literal: true

  class PagesController < ApplicationController
    def home
    end
  end
RUBY

file "app/views/pages/home.html.slim", <<~SLIM
  h1 #{app_name}
SLIM

file ".rspec", "--require spec_helper"

file ""

file "spec/spec_helper.rb", <<~RUBY
  # frozen_string_literal: true

  RSpec.configure do |config|
    config.filter_run_when_matching :focus
    config.disable_monkey_patching!
    config.order = :random
  end
RUBY

file "spec/rails_helper.rb", <<~RUBY
  # frozen_string_literal: true

  require "spec_helper"
  ENV["RAILS_ENV"] ||= "test"
  require File.expand_path("../config/environment", __dir__)
  abort("The Rails environment is running in production mode!") if Rails.env.production?
  require "rspec/rails"

  Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }

  begin
    ActiveRecord::Migration.maintain_test_schema!
  rescue ActiveRecord::PendingMigrationError => e
    puts e.to_s.strip
    exit 1
  end

  RSpec.configure do |config|
    config.include ActiveSupport::Testing::TimeHelpers
    config.include ActiveJob::TestHelper

    config.fixture_path = "\#{::Rails.root}/spec/fixtures"
    config.use_transactional_fixtures = true
    config.infer_spec_type_from_file_location!
    config.filter_rails_from_backtrace!
  end
RUBY

file "spec/system_helper.rb", <<~RUBY
  # frozen_string_literal: true

  require "rails_helper"
  require "rack_session_access/capybara"

  Rails.application.routes.default_url_options[:locale] = :en
  Rails.application.routes.default_url_options[:debug] = true

  RSpec.configure do |config|
    config.before(:each, type: :system) do
      driven_by Capybara.javascript_driver
    end
  end
RUBY

file "spec/support/system/cuprite_setup.rb", <<~RUBY
  # frozen_string_literal: true

  require "capybara/cuprite"

  # Then, we need to register our driver to be able to use it later
  # with #driven_by method.
  Capybara.register_driver(:cuprite) do |app|
    Capybara::Cuprite::Driver.new(
      app,
      **{
        window_size: [1200, 1400],
        # See additional options for Dockerized environment in the respective section of this article
        browser_options: {},
        # Increase Chrome startup wait time (required for stable CI builds)
        process_timeout: 10,
        # Enable debugging capabilities
        inspector: true,
        # Allow running Chrome in a headful mode by setting HEADLESS env
        # var to a falsey value
        headless: Config.headless?
      }
    )
  end

  # Configure Capybara to use :cuprite driver by default
  Capybara.default_driver = Capybara.javascript_driver = :cuprite
RUBY

file "Guardfile", <<~RUBY
  # frozen_string_literal: true

  clearing :on

  guard :rspec, cmd: "bin/rspec" do
    require "guard/rspec/dsl"
    dsl = Guard::RSpec::Dsl.new(self)

    # RSpec files
    rspec = dsl.rspec
    watch(rspec.spec_files)
  end
RUBY

inject_into_file "config/environments/development.rb", before: /end$\s\z/ do
  <<~RUBY
    config.hosts = nil

    config.action_mailer.delivery_method = :letter_opener
    config.active_job.queue_adapter = :sidekiq
  RUBY
end

inject_into_file "config/environments/test.rb", before: /end$\s\z/ do
  <<~RUBY
    config.active_job.queue_adapter = :test
  RUBY
end


inject_into_file "config/environments/production.rb", before: /end$\s\z/ do
  <<~RUBY
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      user_name: ENV["SMTP_USERNAME"],
      password: ENV["SMTP_PASSWORD"],
      address: ENV["SMTP_ADDRESS"],
      port: 587,
      authentication: :login,
      enable_starttls_auto: true
    }
  RUBY
end

run "bundle"

run "bundle binstubs rspec-core"

run "echo !.keep >> .gitignore"
run "echo app/assets/builds >> .gitignore"
run "echo node_modules >> .gitignore"

run "yarn add @hotwired/stimulus @hotwired/turbo-rails @nerdgeschoss/shimmer esbuild typescript"
run "yarn add -D @typescript-eslint/eslint-plugin @typescript-eslint/parser eslint eslint-config-prettier eslint-plugin-prettier prettier livereload"

rails_command "stimulus:manifest:update"
run 'git commit -m "Initial Commit" --allow-empty'
