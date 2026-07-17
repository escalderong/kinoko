require 'rails_helper'

RSpec.describe Order, type: :model do
  it { is_expected.to have_field(:opened_at).of_type(DateTime) }
  it { is_expected.to have_field(:closed_at).of_type(DateTime) }

  it { is_expected.to belong_to(:table) }
  it { is_expected.to have_many(:order_items) }
  it { is_expected.to have_many(:checks) }

  it { is_expected.to validate_presence_of(:opened_at) }

  it 'is valid with valid attributes' do
    expect(build(:order)).to be_valid
  end

  describe 'status enum' do
    it 'defaults to open' do
      order = described_class.new
      expect(order.open?).to be true
    end

    it 'returns true for closed? when status is closed' do
      order = build(:order, status: :closed)
      expect(order.closed?).to be true
      expect(order.open?).to be false
    end
  end

  describe '.open' do
    it 'returns only orders with open status' do
      open_order = create(:order, status: :open)
      create(:order, status: :closed)

      expect(described_class.open.to_a).to eq([ open_order ])
    end
  end
end
