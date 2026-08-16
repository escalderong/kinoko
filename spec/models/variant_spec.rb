require 'rails_helper'

RSpec.describe Variant, type: :model do
  it { is_expected.to belong_to(:variant_group).touch(true) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:sku) }

  it 'is valid with valid attributes' do
    expect(build(:variant)).to be_valid
  end

  it 'defaults price_delta to zero COP' do
    variant = described_class.new
    expect(variant.price_delta).to eq(Money.new(0, "COP"))
  end

  it 'is valid when price_delta is negative but within the base price magnitude' do
    group = create(:variant_group, product: create(:product, base_price: Money.new(1000, "COP")))
    variant = build(:variant, variant_group: group, price_delta: Money.new(-1000, "COP"))

    expect(variant).to be_valid
  end

  it 'is invalid when the negative price_delta exceeds the base price magnitude' do
    group = create(:variant_group, product: create(:product, base_price: Money.new(1000, "COP")))
    variant = build(:variant, variant_group: group, price_delta: Money.new(-1001, "COP"))

    expect(variant).not_to be_valid
    expect(variant.errors[:price_delta]).to be_present
  end
end
