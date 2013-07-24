source 'https://rubygems.org'
ruby "2.0.0"

gem 'sinatra', :require => 'sinatra/base'
gem 'hallon', github: 'Burgestrand/Hallon'
gem 'haml'
group :development do
  gem 'sinatra-contrib', :require => 'sinatra/reloader'
end
group :production do
  gem 'newrelic_rpm'
end
