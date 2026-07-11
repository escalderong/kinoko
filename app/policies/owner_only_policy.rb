class OwnerOnlyPolicy < ApplicationPolicy
  def index?   = owner?
  def create?  = owner?
  def update?  = owner?
  def destroy? = owner?

  private

  def owner?
    user.present? && user.owner?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      user.present? ? scope.where(commerce_id: user.commerce_id) : scope.none
    end
  end
end
