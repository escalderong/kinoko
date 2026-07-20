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

  # No index-management step exists elsewhere in this app (no migrations),
  # so declared indexes (e.g. Order's partial unique index enforcing one
  # open order per table) are otherwise never actually created in the test
  # database, and a spec relying on the DB itself enforcing a constraint
  # would silently pass for the wrong reason. Mongoid.models only contains
  # whatever's already been autoloaded — this early in boot that's nothing —
  # so models must be eager-loaded first, or create_collections/create_indexes
  # silently iterate over an empty list. Collections must exist before
  # indexes can be created on them (MongoDB raises NamespaceNotFound
  # otherwise), hence eager_load! then both steps, in this order.
  config.before(:suite) do
    Rails.application.eager_load!
    Mongoid::Tasks::Database.create_collections
    Mongoid::Tasks::Database.create_indexes
  end
end
