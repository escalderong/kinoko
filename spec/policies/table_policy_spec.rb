require 'rails_helper'

RSpec.describe TablePolicy do
  subject(:policy) { described_class.new(user, table) }

  let(:commerce) { create(:commerce) }
  let(:table) { create(:table, commerce: commerce) }

  context 'when the user is an owner' do
    let(:user) { build(:user, role: :owner, commerce: commerce) }

    it 'permits index?' do
      expect(policy.index?).to be true
    end

    it 'permits create?' do
      expect(policy.create?).to be true
    end

    it 'permits update?' do
      expect(policy.update?).to be true
    end

    it 'permits destroy?' do
      expect(policy.destroy?).to be true
    end
  end

  context 'when the user is an admin' do
    let(:user) { build(:user, :admin, commerce: commerce) }

    it 'denies index?' do
      expect(policy.index?).to be false
    end

    it 'denies create?' do
      expect(policy.create?).to be false
    end

    it 'denies update?' do
      expect(policy.update?).to be false
    end

    it 'denies destroy?' do
      expect(policy.destroy?).to be false
    end
  end

  context 'when the user is a waiter' do
    let(:user) { build(:user, role: :waiter, commerce: commerce) }

    it 'denies index?' do
      expect(policy.index?).to be false
    end

    it 'denies create?' do
      expect(policy.create?).to be false
    end

    it 'denies update?' do
      expect(policy.update?).to be false
    end

    it 'denies destroy?' do
      expect(policy.destroy?).to be false
    end
  end

  describe TablePolicy::Scope do
    let(:user) { build(:user, role: :owner, commerce: commerce) }

    it 'resolves to tables belonging to the user commerce' do
      other_commerce = create(:commerce)
      other_table = create(:table, commerce: other_commerce)
      table

      resolved = described_class.new(user, Table.all).resolve

      expect(resolved.to_a).to eq([ table ])
      expect(resolved.to_a).not_to include(other_table)
    end

    context 'when the user is nil' do
      it 'resolves to an empty scope' do
        resolved = described_class.new(nil, Table.all).resolve

        expect(resolved.to_a).to eq([])
      end
    end
  end
end
