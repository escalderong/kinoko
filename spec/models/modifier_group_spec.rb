require 'rails_helper'

RSpec.describe ModifierGroup, type: :model do
  it { is_expected.to have_field(:name).of_type(String) }
  it { is_expected.to have_field(:is_required).of_type(Mongoid::Boolean).with_default_value_of(false) }
  it { is_expected.to have_field(:min_selected).of_type(Integer).with_default_value_of(0) }
  it { is_expected.to have_field(:max_selected).of_type(Integer) }

  it { is_expected.to belong_to(:product) }
  it { is_expected.to have_many(:modifiers) }

  it { is_expected.to validate_presence_of(:name) }

  it 'is valid with valid attributes' do
    expect(build(:modifier_group)).to be_valid
  end
end
