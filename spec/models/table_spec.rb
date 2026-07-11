require 'rails_helper'

RSpec.describe Table, type: :model do
  it { is_expected.to have_field(:capacity).of_type(Integer) }
  it { is_expected.to have_field(:number).of_type(Integer) }
  it { is_expected.to have_field(:pos_x).of_type(Integer) }
  it { is_expected.to have_field(:pos_y).of_type(Integer) }
  it { is_expected.to have_field(:width).of_type(Integer) }
  it { is_expected.to have_field(:height).of_type(Integer) }

  it { is_expected.to belong_to(:commerce) }
  it { is_expected.to belong_to(:floor_zone) }

  it { is_expected.to validate_presence_of(:number) }
  it { is_expected.to validate_presence_of(:capacity) }

  it { is_expected.to validate_numericality_of(:pos_x).greater_than_or_equal_to(0) }
  it { is_expected.to validate_numericality_of(:pos_y).greater_than_or_equal_to(0) }
  it { is_expected.to validate_numericality_of(:width).greater_than_or_equal_to(1) }
  it { is_expected.to validate_numericality_of(:height).greater_than_or_equal_to(1) }

  it 'is valid with valid attributes' do
    expect(build(:table)).to be_valid
  end

  describe 'status enum' do
    it 'returns true for available? when status is available' do
      table = build(:table, status: :available)
      expect(table.available?).to be true
    end

    it 'returns true for reserved? when status is reserved' do
      table = build(:table, status: :reserved)
      expect(table.reserved?).to be true
    end

    it 'returns true for occupied? when status is occupied' do
      table = build(:table, status: :occupied)
      expect(table.occupied?).to be true
    end
  end

  describe 'number uniqueness scoped to commerce' do
    it 'is valid when two tables share a number but belong to different commerces' do
      commerce_a = create(:commerce)
      commerce_b = create(:commerce)
      create(:table, commerce: commerce_a, number: 1)
      table = build(:table, commerce: commerce_b, number: 1)

      expect(table).to be_valid
    end

    it 'is invalid when two tables share a number within the same commerce' do
      commerce = create(:commerce)
      create(:table, commerce: commerce, number: 1)
      table = build(:table, commerce: commerce, number: 1)

      expect(table).not_to be_valid
      expect(table.errors[:number]).to be_present
    end
  end
end
