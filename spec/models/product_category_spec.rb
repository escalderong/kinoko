require 'rails_helper'

RSpec.describe ProductCategory, type: :model do
  it { is_expected.to belong_to(:commerce).touch(true) }
  it { is_expected.to have_many(:products).dependent(:restrict_with_error) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:icon) }

  it { is_expected.to have_db_index([ :commerce_id, :name ]).unique(true) }

  it 'is valid with valid attributes' do
    expect(build(:product_category)).to be_valid
  end

  describe 'name uniqueness scoped to commerce' do
    it 'is valid when two categories share a name but belong to different commerces' do
      commerce_a = create(:commerce)
      commerce_b = create(:commerce)
      create(:product_category, commerce: commerce_a, name: "Drinks")
      category = build(:product_category, commerce: commerce_b, name: "Drinks")

      expect(category).to be_valid
    end

    it 'is invalid when two categories share a name within the same commerce' do
      commerce = create(:commerce)
      create(:product_category, commerce: commerce, name: "Drinks")
      category = build(:product_category, commerce: commerce, name: "Drinks")

      expect(category).not_to be_valid
      expect(category.errors[:name]).to be_present
    end
  end

  it 'exposes a curated list of picker icons' do
    expect(ProductCategory::ICONS).to be_an(Array)
    expect(ProductCategory::ICONS).to all(be_a(String))
    expect(ProductCategory::ICONS).not_to be_empty
  end
end
