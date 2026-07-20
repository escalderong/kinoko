RSpec.configure do |config|
  config.before(:suite) do
    Mongoid.purge!
  end

  # `purge!` drops every collection outright, taking any declared indexes
  # (e.g. Order's partial unique index) down with it — so an index created
  # once in the before(:suite) hook silently stops existing after the very
  # first example. `truncate!` clears documents via delete_many instead,
  # leaving collections (and their indexes) intact across examples.
  config.after(:each) do
    Mongoid.truncate!
  end
end
