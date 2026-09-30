# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'rake', '~> 13.0.0'

if RUBY_VERSION >= '3.5'
  gem 'logger'
  gem 'ostruct'
end

if RUBY_VERSION >= '2.6'
  gem 'rspec', '~> 3.13.0'
else
  gem 'rspec', '~> 3.9.0'
end

if RUBY_ENGINE == 'ruby' && RUBY_VERSION >= '2.7'
  group :coverage do
    gem 'deep-cover-core', '~> 1.1.0', require: false
    gem 'simplecov', '~> 0.22.0', require: false
  end

  group :lint do
    gem 'rubocop', '~> 1.68.0', require: false
    gem 'rubocop-rake', '~> 0.6.0', require: false
    gem 'rubocop-rspec', '~> 3.2.0', require: false
  end
end
