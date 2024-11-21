source 'https://rubygems.org'

ruby '2.6.6'

gem 'active_model_serializers', '0.9.12'
gem 'activerecord-connections', git: 'https://github.com/portabilis/activerecord-connections.git'
gem "activerecord-tablefree", "~> 3.0"
gem 'audited', git: 'https://github.com/portabilis/audited.git'
gem 'aws-sdk-s3', '~>1.83.0'
gem 'backbone-nested-attributes', '0.3.0', git: 'https://github.com/samuelsimoes/backbone-nested-attributes.git'
gem 'binding_of_caller', '1.0.0'
gem 'bootbox-rails', '~>0.4'
gem 'bootsnap'
gem 'bootstrap3-datetimepicker-rails', '~> 4.17.47'
gem 'browser', '~> 4.1.0'
gem 'carrierwave', '>= 1.3.2'
gem 'carrierwave-aws', '~>1.4.0'
gem 'cocoon', '1.2.6'
gem 'cpf_cnpj', '0.3.0'
gem 'dalli', '2.7.10'
gem 'decore', '0.1.0', git: 'https://github.com/matiasleidemer/decore'
gem 'deferring', '0.5.0'
gem 'devise', '>= 4.7.1'
gem 'dry-inflector', '0.1.2'
gem 'discard', '1.0.0'
gem 'ejs', '1.1.1'
gem 'enumerate_it', '1.3.1'
gem 'handlebars_assets', '0.23.2'
gem 'has_scope', '0.7.2'
gem 'honeybadger', '5.5.0'
gem 'i18n_alchemy', '0.3.1'
gem 'jbuilder', '2.9.1'
gem 'js-routes', '1.4.9'
gem 'kaminari', '>= 1.2.1'
gem 'less-rails', '3.0.0'
gem 'loofah', '2.20.0'
gem 'mask_validator', '0.2.1'
gem 'momentjs-rails', '>= 2.9.0'
gem 'non-stupid-digest-assets', '1.0.9'
gem 'pg', '~> 0.18.0'
gem 'pg_query', '1.2.0'
gem 'postgres-copy', '1.0.0'
gem 'prawn', '2.1.2', git: 'https://github.com/portabilis/prawn.git', branch: 'master'
gem 'prawn-table', '0.2.2'
gem 'puma', '~> 6.4'
gem 'pundit', '0.3.0'
gem 'rack-cors', '>= 1.0.4 ', require: 'rack/cors'
gem 'rack-protection', '1.5.5'
gem 'rails', '5.0.7.2'
gem 'rake', '>= 12.3.3'
gem 'redis-rails'
gem 'responders', '2.4.1'
gem 'rest-client', '2.0.2'
gem 'route_translator', git: 'https://github.com/enriclluelles/route_translator.git', tag: 'v5.10.0'
gem 'rubyzip', '>= 1.3.0', require: 'zip'
gem 'sidekiq', '5.2.9'
gem 'sidekiq-unique-jobs', '6.0.25'
gem 'signet', '0.11.0'
gem 'simple_form', '4.0.0'
gem 'therubyracer', '0.12.3'
gem 'twitter-bootstrap-rails', '3.2.2'
gem 'uglifier', '4.1.20'
gem 'uri_validator', '0.2.0'
gem 'validates_timeliness', '3.0.14'
gem 'webpacker', '~> 4.x'
gem 'scenic', '~> 1.7'
gem 'tilt', '2.1.0'

instance_eval File.read('Gemfile.plugins') if File.exist?('Gemfile.plugins')

group :development do
  gem 'rack-mini-profiler', '~> 2.3.4'
  gem 'meta_request', '0.7.4'
  gem 'pry-byebug', '3.4.2'
  gem 'rubocop', '1.10', require: false
  gem 'rubocop-rails'
  gem 'spring', '2.1.1'
  gem 'spring-commands-rspec', '1.0.4'
  gem 'letter_opener_web', '~> 1.3.4'
  gem 'listen', '~> 3.0.5'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'business_time', '0.9.3'
  gem 'capybara', '2.5.0'
  gem 'cpf_faker', '1.3.0'
  gem 'database_cleaner', '1.5.1'
  gem 'factory_girl_rails', '4.5.0'
  gem 'faker', '1.9.1'
  gem 'gherkin', '2.12.2'
  gem 'nokogiri', '1.9.1'
  gem 'pdf-inspector', '1.2.1', require: 'pdf/inspector'
  gem 'pry', '0.10.3'
  gem 'rails-controller-testing', '~> 1.0.5'
  gem 'rspec-rails', '3.5.2'
  gem 'rspec-retry', '0.6.2 '
  gem 'rspec-sidekiq', '3.0.3'
  gem 'rspec-wait', '0.0.9'
  gem 'selenium-webdriver', '~> 3.0'
  gem 'shoulda-matchers', '~> 3.1', '>= 3.1.0'
  gem 'timecop', '0.8.1'
  gem 'turnip', '1.3.1'
  gem 'vcr', '3.0.0'
  gem 'webdrivers', '3.6.0'
  gem 'webmock', '3.14.0'
  gem 'simplecov', require: false
  gem 'net-http', '0.4.1'
end

group :test, :development do
  gem 'bullet', '6.1.5'
end
