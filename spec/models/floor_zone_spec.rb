require 'rails_helper'

RSpec.describe FloorZone, type: :model do
  it { is_expected.to have_field(:name).of_type(String) }
  it { is_expected.to have_field(:position).of_type(Integer) }

  it { is_expected.to belong_to(:commerce) }
  it { is_expected.to have_many(:tables) }

  it { is_expected.to validate_presence_of(:name) }

  it 'is valid with valid attributes' do
    expect(build(:floor_zone)).to be_valid
  end
end
