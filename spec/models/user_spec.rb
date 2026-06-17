require 'rails_helper'

RSpec.describe User, type: :model do
  it { is_expected.to have_field(:email).of_type(String) }
  it { is_expected.to have_field(:encrypted_password).of_type(String) }
  it { is_expected.to have_field(:reset_password_token).of_type(String) }
  it { is_expected.to have_field(:reset_password_sent_at).of_type(Time) }
  it { is_expected.to have_field(:remember_created_at).of_type(Time) }
  it { is_expected.to have_field(:name).of_type(String) }
  it { is_expected.to have_field(:locale).of_type(String) }

  it { is_expected.to belong_to(:commerce) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:role) }

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
