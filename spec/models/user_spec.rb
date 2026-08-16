require 'rails_helper'

RSpec.describe User, type: :model do
  it { is_expected.to belong_to(:commerce) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:role) }

  it { is_expected.to define_enum_for(:role).with_values(owner: 0, admin: 1, waiter: 2, cashier: 3) }

  it 'is valid with valid attributes' do
    expect(build(:user)).to be_valid
  end

  describe 'locale' do
    it 'defaults to I18n.default_locale' do
      user = build(:user)
      expect(user.locale).to eq(I18n.default_locale.to_s)
    end

    it 'is valid with an available locale' do
      user = build(:user, locale: 'es')
      expect(user).to be_valid
    end

    it 'is invalid with a locale not in I18n.available_locales' do
      user = build(:user, locale: 'fr')
      expect(user).not_to be_valid
      expect(user.errors[:locale]).to be_present
    end
  end

  describe 'role enum' do
    it 'returns true for owner? when role is owner' do
      user = build(:user, role: :owner)
      expect(user.owner?).to be true
      expect(user.admin?).to be false
      expect(user.waiter?).to be false
    end

    it 'returns true for admin? when role is admin' do
      user = build(:user, role: :admin)
      expect(user.admin?).to be true
      expect(user.owner?).to be false
    end

    it 'returns true for waiter? when role is waiter' do
      user = build(:user, role: :waiter)
      expect(user.waiter?).to be true
      expect(user.owner?).to be false
    end

    it 'returns true for cashier? when role is cashier' do
      user = build(:user, role: :cashier)
      expect(user.cashier?).to be true
      expect(user.owner?).to be false
    end
  end

  describe 'devise :validatable' do
    it 'is invalid without an email' do
      user = build(:user, email: '')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end

    it 'is invalid with a duplicate email' do
      create(:user, email: 'duplicate@example.com')
      user = build(:user, email: 'duplicate@example.com')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end
  end
end
