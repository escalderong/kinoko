require 'rails_helper'

RSpec.describe Commerce, type: :model do
  it { is_expected.to have_field(:name).of_type(String) }
  it { is_expected.to have_field(:theme).of_type(String) }

  it { is_expected.to have_many(:product_categories) }
  it { is_expected.to have_many(:tables) }
  it { is_expected.to have_many(:users) }

  it { is_expected.to validate_presence_of(:name) }

  it 'is valid with valid attributes' do
    expect(build(:commerce)).to be_valid
  end

  describe 'theme' do
    it 'defaults to "light"' do
      expect(build(:commerce).theme).to eq('light')
    end
  end
end
