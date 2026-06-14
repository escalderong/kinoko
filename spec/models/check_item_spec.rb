require 'rails_helper'

RSpec.describe CheckItem, type: :model do
  it { is_expected.to have_field(:quantity).of_type(Integer) }

  it { is_expected.to belong_to(:check) }
  it { is_expected.to belong_to(:order_item) }

  it { is_expected.to validate_presence_of(:quantity) }
  it { is_expected.to validate_numericality_of(:quantity) }

  it 'is invalid when quantity is zero' do
    check_item = build(:check_item, quantity: 0)
    expect(check_item).not_to be_valid
    expect(check_item.errors[:quantity]).to be_present
  end

  it 'is invalid when quantity is negative' do
    check_item = build(:check_item, quantity: -1)
    expect(check_item).not_to be_valid
    expect(check_item.errors[:quantity]).to be_present
  end

  it 'is valid with valid attributes' do
    expect(build(:check_item)).to be_valid
  end

  describe '#complete_item_price' do
    it 'delegates to order_item#complete_item_price' do
      order_item = create(:order_item, base_price: Money.new(10_000, "COP"))
      create(:order_item_variant, order_item: order_item, price_delta: Money.new(2_000, "COP"))
      create(:order_item_modifier, order_item: order_item, price_delta: Money.new(1_500, "COP"))

      check_item = create(:check_item, order_item: order_item)

      expect(check_item.complete_item_price).to eq(order_item.complete_item_price)
      expect(check_item.complete_item_price).to eq(Money.new(13_500, "COP"))
    end
  end
end
