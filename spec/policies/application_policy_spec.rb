require 'rails_helper'

RSpec.describe ApplicationPolicy do
  subject(:policy) { described_class.new(user, record) }

  let(:user) { build(:user) }
  let(:record) { double("record") }

  describe 'default predicates' do
    it 'permits index?' do
      expect(policy.index?).to be true
    end

    it 'permits show?' do
      expect(policy.show?).to be true
    end

    it 'permits create?' do
      expect(policy.create?).to be true
    end

    it 'permits new?' do
      expect(policy.new?).to be true
    end

    it 'permits update?' do
      expect(policy.update?).to be true
    end

    it 'permits edit?' do
      expect(policy.edit?).to be true
    end

    it 'permits destroy?' do
      expect(policy.destroy?).to be true
    end
  end

  describe ApplicationPolicy::Scope do
    it 'raises NoMethodError when #resolve is not overridden' do
      scope = described_class.new(user, double("scope"))
      expect { scope.resolve }.to raise_error(NoMethodError)
    end
  end
end
