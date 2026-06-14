require 'rails_helper'

RSpec.describe Variant, type: :model do
  it { is_expected.to have_field(:name).of_type(String) }
  it { is_expected.to have_field(:sku).of_type(String) }
  it { is_expected.to have_field(:price_delta).of_type(Money) }

  it { is_expected.to belong_to(:variant_group) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:sku) }

  it 'is valid with valid attributes' do
    expect(build(:variant)).to be_valid
  end

  it 'defaults price_delta to zero COP' do
    variant = described_class.new
    expect(variant.price_delta).to eq(Money.new(0, "COP"))
  end
end
