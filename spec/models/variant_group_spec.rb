require 'rails_helper'

RSpec.describe VariantGroup, type: :model do
  it { is_expected.to have_field(:name).of_type(String) }
  it { is_expected.to have_field(:is_required).of_type(Mongoid::Boolean).with_default_value_of(false) }

  it { is_expected.to belong_to(:product) }
  it { is_expected.to have_many(:variants) }

  it { is_expected.to validate_presence_of(:name) }

  it 'is valid with valid attributes' do
    expect(build(:variant_group)).to be_valid
  end
end
