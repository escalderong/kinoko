require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  it { is_expected.to have_field(:base_price).of_type(Money) }
  it { is_expected.to have_field(:fired_at).of_type(DateTime) }
  it { is_expected.to have_field(:product_name).of_type(String) }
  it { is_expected.to have_field(:quantity).of_type(Integer) }
  it { is_expected.to have_field(:notes).of_type(String) }

  it { is_expected.to belong_to(:order) }
  it { is_expected.to have_many(:order_item_variants) }
  it { is_expected.to have_many(:order_item_modifiers) }
  it { is_expected.to have_many(:check_items) }

  it { is_expected.to validate_presence_of(:base_price) }
  it { is_expected.to validate_presence_of(:product_name) }
  it { is_expected.to validate_presence_of(:quantity) }
  it { is_expected.to validate_numericality_of(:quantity) }

  it 'is invalid when quantity is zero' do
    order_item = build(:order_item, quantity: 0)
    expect(order_item).not_to be_valid
    expect(order_item.errors[:quantity]).to be_present
  end

  it 'is invalid when quantity is negative' do
    order_item = build(:order_item, quantity: -1)
    expect(order_item).not_to be_valid
    expect(order_item.errors[:quantity]).to be_present
  end

  it 'is valid with valid attributes' do
    expect(build(:order_item)).to be_valid
  end

  describe '#complete_item_price' do
    it 'equals base_price when there are no variants or modifiers' do
      order_item = create(:order_item, base_price: Money.new(10_000, "COP"))

      expect(order_item.complete_item_price).to eq(Money.new(10_000, "COP"))
    end

    it 'adds variant and modifier price deltas to the base price' do
      order_item = create(:order_item, base_price: Money.new(10_000, "COP"))
      create(:order_item_variant, order_item: order_item, price_delta: Money.new(2_000, "COP"))
      create(:order_item_variant, order_item: order_item, price_delta: Money.new(500, "COP"))
      create(:order_item_modifier, order_item: order_item, price_delta: Money.new(1_500, "COP"))

      expect(order_item.complete_item_price).to eq(Money.new(14_000, "COP"))
    end
  end

  describe 'table broadcasting' do
    it 'broadcasts a table replace to the commerce stream on create' do
      table = create(:table)
      allow(Turbo::StreamsChannel).to receive(:broadcast_replace_to)
      order = create(:order, table: table)

      expect(Turbo::StreamsChannel).to receive(:broadcast_replace_to).with(
        "commerce_#{table.commerce_id}_tables",
        target: ActionView::RecordIdentifier.dom_id(table),
        partial: "app/tables/table",
        locals: { table: table, open: true }
      )

      create(:order_item, order: order)
    end

    it 'broadcasts a table replace to the commerce stream on destroy' do
      table = create(:table)
      allow(Turbo::StreamsChannel).to receive(:broadcast_replace_to)
      order = create(:order, table: table)
      order_item = create(:order_item, order: order)

      expect(Turbo::StreamsChannel).to receive(:broadcast_replace_to).with(
        "commerce_#{table.commerce_id}_tables",
        target: ActionView::RecordIdentifier.dom_id(table),
        partial: "app/tables/table",
        locals: { table: table, open: true }
      )

      order_item.destroy
    end
  end
end
