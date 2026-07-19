require 'rails_helper'

RSpec.describe Modifier, type: :model do
  it { is_expected.to have_field(:name).of_type(String) }
  it { is_expected.to have_field(:price_delta).of_type(Money) }
  it { is_expected.to have_field(:is_active).of_type(Mongoid::Boolean).with_default_value_of(true) }

  it { is_expected.to belong_to(:modifier_group) }

  it { is_expected.to validate_presence_of(:name) }

  it 'is valid with valid attributes' do
    expect(build(:modifier)).to be_valid
  end

  it 'defaults price_delta to zero COP' do
    modifier = described_class.new
    expect(modifier.price_delta).to eq(Money.new(0, "COP"))
  end

  it 'is valid when price_delta is negative but within the base price magnitude' do
    group = create(:modifier_group, product: create(:product, base_price: Money.new(1000, "COP")))
    modifier = build(:modifier, modifier_group: group, price_delta: Money.new(-1000, "COP"))

    expect(modifier).to be_valid
  end

  it 'is invalid when the negative price_delta exceeds the base price magnitude' do
    group = create(:modifier_group, product: create(:product, base_price: Money.new(1000, "COP")))
    modifier = build(:modifier, modifier_group: group, price_delta: Money.new(-1001, "COP"))

    expect(modifier).not_to be_valid
    expect(modifier.errors[:price_delta]).to be_present
  end
end
