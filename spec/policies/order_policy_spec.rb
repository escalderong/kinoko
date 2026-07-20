require "rails_helper"

RSpec.describe OrderPolicy do
  subject(:policy) { described_class.new(user, Order) }

  let(:commerce) { create(:commerce) }

  context "when the user is an owner" do
    let(:user) { build(:user, role: :owner, commerce: commerce) }

    it { expect(policy.create?).to be true }
  end

  context "when the user is an admin" do
    let(:user) { build(:user, :admin, commerce: commerce) }

    it { expect(policy.create?).to be true }
  end

  context "when the user is a waiter" do
    let(:user) { build(:user, :waiter, commerce: commerce) }

    it { expect(policy.create?).to be true }
  end

  context "when there is no user" do
    let(:user) { nil }

    it { expect(policy.create?).to be false }
  end

  describe "#checkout?" do
    context "when the user is an owner" do
      let(:user) { build(:user, role: :owner, commerce: commerce) }

      it { expect(policy.checkout?).to be true }
    end

    context "when the user is an admin" do
      let(:user) { build(:user, :admin, commerce: commerce) }

      it { expect(policy.checkout?).to be true }
    end

    context "when the user is a cashier" do
      let(:user) { build(:user, :cashier, commerce: commerce) }

      it { expect(policy.checkout?).to be true }
    end

    context "when the user is a waiter" do
      let(:user) { build(:user, :waiter, commerce: commerce) }

      it { expect(policy.checkout?).to be false }
    end

    context "when there is no user" do
      let(:user) { nil }

      it { expect(policy.checkout?).to be false }
    end
  end
end
