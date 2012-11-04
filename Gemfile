source 'https://rubygems.org'



#ruby '1.9.3'

#gem 'bundler', '1.2.0.pre'
gem 'rails', '3.2.3'








# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'


group :production do

  gem "heroku"
  gem 'pg'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do

  gem 'less-rails'
  gem 'therubyracer'
  gem 'libv8', '3.3.10.4'

  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer'

  gem 'uglifier', '>= 1.0.3'

end

gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

gem 'twitter-bootstrap-rails'
gem 'rails-backbone', '0.7.0'

gem 'thin'
gem 'jasmine'
gem 'jasminerice'
  
group :development, :test do
#gem 'activerecord-sqlite3-adapter'
  gem 'sqlite3', '1.3.5'
  gem 'guard'
  gem 'guard-jasmine'
  gem 'guard-coffeescript'
  gem 'guard-livereload'

  gem 'rb-inotify', '~> 0.8.8'
end


