require 'rails_helper'

RSpec.describe FloorZonePolicy do
  subject(:policy) { described_class.new(user, floor_zone) }

  let(:commerce) { create(:commerce) }
  let(:floor_zone) { create(:floor_zone, commerce: commerce) }

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

  describe FloorZonePolicy::Scope do
    let(:user) { build(:user, role: :owner, commerce: commerce) }

    it 'resolves to floor zones belonging to the user commerce' do
      other_commerce = create(:commerce)
      other_floor_zone = create(:floor_zone, commerce: other_commerce)
      floor_zone

      resolved = described_class.new(user, FloorZone.all).resolve

      expect(resolved.to_a).to eq([ floor_zone ])
      expect(resolved.to_a).not_to include(other_floor_zone)
    end

    context 'when the user is nil' do
      it 'resolves to an empty scope' do
        resolved = described_class.new(nil, FloorZone.all).resolve

        expect(resolved.to_a).to eq([])
      end
    end
  end
end
