require 'rails_helper'

RSpec.describe OrderItemVariant, type: :model do
  it { is_expected.to belong_to(:order_item) }

  it { is_expected.to validate_presence_of(:variant_group_name) }
  it { is_expected.to validate_presence_of(:variant_name) }

  it 'is valid with valid attributes' do
    expect(build(:order_item_variant)).to be_valid
  end

  it 'defaults price_delta to zero COP' do
    order_item_variant = described_class.new
    expect(order_item_variant.price_delta).to eq(Money.new(0, "COP"))
  end
end
