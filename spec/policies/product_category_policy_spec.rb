require 'rails_helper'

RSpec.describe ProductCategoryPolicy do
  subject(:policy) { described_class.new(user, category) }

  let(:commerce) { create(:commerce) }
  let(:category) { create(:product_category, commerce: commerce) }

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

  describe ProductCategoryPolicy::Scope do
    let(:user) { build(:user, role: :owner, commerce: commerce) }

    it 'resolves to categories belonging to the user commerce' do
      other_commerce = create(:commerce)
      other_category = create(:product_category, commerce: other_commerce)
      category

      resolved = described_class.new(user, ProductCategory.all).resolve

      expect(resolved.to_a).to eq([ category ])
      expect(resolved.to_a).not_to include(other_category)
    end

    context 'when the user is nil' do
      it 'resolves to an empty scope' do
        resolved = described_class.new(nil, ProductCategory.all).resolve

        expect(resolved.to_a).to eq([])
      end
    end
  end
end
