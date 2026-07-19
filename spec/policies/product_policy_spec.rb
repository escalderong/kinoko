require 'rails_helper'

RSpec.describe ProductPolicy do
  subject(:policy) { described_class.new(user, product) }

  let(:commerce) { create(:commerce) }
  let(:product) { create(:product, commerce: commerce) }

  context 'when the user is an owner' do
    let(:user) { build(:user, role: :owner, commerce: commerce) }

    it { expect(policy.index?).to be true }
    it { expect(policy.create?).to be true }
    it { expect(policy.update?).to be true }
    it { expect(policy.destroy?).to be true }
  end

  context 'when the user is an admin' do
    let(:user) { build(:user, :admin, commerce: commerce) }

    it { expect(policy.index?).to be true }
    it { expect(policy.create?).to be true }
    it { expect(policy.update?).to be true }
    it { expect(policy.destroy?).to be true }
  end

  context 'when the user is a waiter' do
    let(:user) { build(:user, role: :waiter, commerce: commerce) }

    it { expect(policy.index?).to be false }
    it { expect(policy.create?).to be false }
    it { expect(policy.update?).to be false }
    it { expect(policy.destroy?).to be false }
  end

  describe ProductPolicy::Scope do
    let(:user) { build(:user, role: :owner, commerce: commerce) }

    it 'resolves to products belonging to the user commerce' do
      other_commerce = create(:commerce)
      other_product = create(:product, commerce: other_commerce)
      product

      resolved = described_class.new(user, Product.all).resolve

      expect(resolved.to_a).to eq([ product ])
      expect(resolved.to_a).not_to include(other_product)
    end

    context 'when the user is nil' do
      it 'resolves to an empty scope' do
        resolved = described_class.new(nil, Product.all).resolve

        expect(resolved.to_a).to eq([])
      end
    end
  end
end
