require 'rails_helper'

RSpec.describe Commerce, type: :model do
  it { is_expected.to have_field(:name).of_type(String) }
  it { is_expected.to have_field(:theme).of_type(String) }

  it { is_expected.to have_many(:product_categories) }
  it { is_expected.to have_many(:tables) }
  it { is_expected.to have_many(:users) }
  it { is_expected.to have_many(:floor_zones) }

  it { is_expected.to validate_presence_of(:name) }

  it 'is valid with valid attributes' do
    expect(build(:commerce)).to be_valid
  end

  describe 'THEMES' do
    it 'stays in sync with the daisyUI themes compiled in application.css' do
      css = Rails.root.join('app/assets/tailwind/application.css').read
      declared = css[/themes:\s*(.+?);/m, 1]
      css_themes = declared.split(',').map { |token| token.strip.split(/\s+/).first }

      expect(css_themes).to match_array(Commerce::THEMES)
    end
  end

  describe 'theme' do
    it 'defaults to the model default theme' do
      expect(build(:commerce).theme).to eq(Commerce::DEFAULT_THEME)
    end

    it 'is valid with a theme in the allowed list' do
      expect(build(:commerce, theme: 'dracula')).to be_valid
    end

    it 'is invalid with a theme outside the allowed list' do
      commerce = build(:commerce, theme: 'not-a-real-theme')

      expect(commerce).not_to be_valid
      expect(commerce.errors[:theme]).to be_present
    end
  end
end
