# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
require 'mongoid-rspec'

Rails.root.glob('spec/support/**/*.rb').sort_by(&:to_s).each { |f| require f }

RSpec.configure do |config|
  config.use_active_record = false

  config.infer_spec_type_from_file_location!

  config.include Mongoid::Matchers, type: :model
  config.include FactoryBot::Syntax::Methods

  config.filter_rails_from_backtrace!
end
