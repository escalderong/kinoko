require 'rails_helper'

RSpec.describe Product, type: :model do
  it { is_expected.to have_field(:name).of_type(String) }
  it { is_expected.to have_field(:is_active).of_type(Mongoid::Boolean).with_default_value_of(true) }
  it { is_expected.to have_field(:base_price).of_type(Money) }

  it { is_expected.to belong_to(:product_category) }
  it { is_expected.to have_many(:variant_groups) }
  it { is_expected.to have_many(:modifier_groups) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:base_price) }

  it 'is valid with valid attributes' do
    expect(build(:product)).to be_valid
  end
end
