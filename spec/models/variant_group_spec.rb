require 'rails_helper'

RSpec.describe VariantGroup, type: :model do
  it { is_expected.to belong_to(:product).touch(true) }
  it { is_expected.to have_many(:variants).dependent(:destroy) }

  it { is_expected.to validate_presence_of(:name) }

  it 'is valid with valid attributes' do
    expect(build(:variant_group)).to be_valid
  end
end
