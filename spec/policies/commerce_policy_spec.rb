require 'rails_helper'

RSpec.describe CommercePolicy do
  subject(:policy) { described_class.new(user, commerce) }

  let(:commerce) { create(:commerce) }

  context 'when the user is an owner' do
    let(:user) { build(:user, role: :owner, commerce: commerce) }

    it 'permits settings?' do
      expect(policy.settings?).to be true
    end

    it 'permits manage_users?' do
      expect(policy.manage_users?).to be true
    end

    it 'permits update?' do
      expect(policy.update?).to be true
    end

    it 'permits edit?' do
      expect(policy.edit?).to be true
    end

    it 'permits view_orders?' do
      expect(policy.view_orders?).to be true
    end

    it 'permits view_products?' do
      expect(policy.view_products?).to be true
    end
  end

  context 'when the user is an admin' do
    let(:user) { build(:user, :admin, commerce: commerce) }

    it 'permits view_orders?' do
      expect(policy.view_orders?).to be true
    end

    it 'permits view_products?' do
      expect(policy.view_products?).to be true
    end
  end

  context 'when the user is a waiter' do
    let(:user) { build(:user, role: :waiter, commerce: commerce) }

    it 'denies settings?' do
      expect(policy.settings?).to be false
    end

    it 'denies manage_users?' do
      expect(policy.manage_users?).to be false
    end

    it 'denies update?' do
      expect(policy.update?).to be false
    end

    it 'denies edit?' do
      expect(policy.edit?).to be false
    end

    it 'permits view_orders?' do
      expect(policy.view_orders?).to be true
    end

    it 'denies view_products?' do
      expect(policy.view_products?).to be false
    end
  end

  describe CommercePolicy::Scope do
    let(:user) { build(:user, role: :owner, commerce: commerce) }

    it 'resolves to commerces belonging to the user' do
      other_commerce = create(:commerce, name: "Other")
      resolved = described_class.new(user, Commerce.all).resolve

      expect(resolved.to_a).to eq([ commerce ])
      expect(resolved.to_a).not_to include(other_commerce)
    end

    context 'when the user is nil' do
      it 'resolves to an empty scope' do
        resolved = described_class.new(nil, Commerce.all).resolve

        expect(resolved.to_a).to eq([])
      end
    end
  end
end
