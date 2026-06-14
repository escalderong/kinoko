require 'rails_helper'

RSpec.describe ProductCategory, type: :model do
  it { is_expected.to have_field(:name).of_type(String) }

  it { is_expected.to have_many(:products) }

  it { is_expected.to validate_presence_of(:name) }

  it 'is valid with valid attributes' do
    expect(build(:product_category)).to be_valid
  end
end
