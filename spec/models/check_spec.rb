require 'rails_helper'

RSpec.describe Check, type: :model do
  it { is_expected.to belong_to(:order) }

  it 'is valid with valid attributes' do
    expect(build(:check)).to be_valid
  end

  it 'defaults to open status' do
    expect(described_class.new.status).to eq('open')
  end

  describe 'status enum' do
    it 'returns true for open? when status is open' do
      check = build(:check, status: :open)
      expect(check.open?).to be true
    end

    it 'returns true for paid? when status is paid' do
      check = build(:check, status: :paid)
      expect(check.paid?).to be true
      expect(check.open?).to be false
    end
  end

  describe '#total' do
    it 'equals zero COP when subtotal, tax and tip are default' do
      check = build(:check)
      expect(check.total).to eq(Money.new(0, "COP"))
    end

    it 'sums subtotal, tax and tip' do
      check = build(:check,
        subtotal: Money.new(10_000, "COP"),
        tax: Money.new(1_900, "COP"),
        tip: Money.new(1_000, "COP"))

      expect(check.total).to eq(Money.new(12_900, "COP"))
    end
  end
end
