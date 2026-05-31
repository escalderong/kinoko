RSpec.configure do |config|
  config.before(:suite) do
    Mongoid.purge!
  end

  config.after(:each) do
    Mongoid.purge!
  end
end
