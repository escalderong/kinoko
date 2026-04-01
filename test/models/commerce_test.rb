require "test_helper"

class CommerceTest < ActiveSupport::TestCase
  context "validations" do
    should validate_presence_of(:name)
  end
end
