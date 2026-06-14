require 'rails_helper'

RSpec.describe OrderItemModifier, type: :model do
  it { is_expected.to have_field(:modifier_group_name).of_type(String) }
  it { is_expected.to have_field(:modifier_name).of_type(String) }
  it { is_expected.to have_field(:price_delta).of_type(Money) }

  it { is_expected.to belong_to(:order_item) }

  it { is_expected.to validate_presence_of(:modifier_group_name) }
  it { is_expected.to validate_presence_of(:modifier_name) }

  it 'is valid with valid attributes' do
    expect(build(:order_item_modifier)).to be_valid
  end

  it 'defaults price_delta to zero COP' do
    order_item_modifier = described_class.new
    expect(order_item_modifier.price_delta).to eq(Money.new(0, "COP"))
  end
end
