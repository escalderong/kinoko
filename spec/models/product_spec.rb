require 'rails_helper'

RSpec.describe Product, type: :model do
  it { is_expected.to belong_to(:product_category) }
  it { is_expected.to belong_to(:commerce).touch(true) }
  it { is_expected.to have_many(:variant_groups).dependent(:destroy) }
  it { is_expected.to have_many(:modifier_groups).dependent(:destroy) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:base_price) }

  it 'is valid with valid attributes' do
    expect(build(:product)).to be_valid
  end
end
