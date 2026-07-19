class OwnerAdminPolicy < ApplicationPolicy
  def index?   = owner_or_admin?
  def create?  = owner_or_admin?
  def update?  = owner_or_admin?
  def destroy? = owner_or_admin?

  private

  def owner_or_admin?
    user.present? && (user.owner? || user.admin?)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      user.present? ? scope.where(commerce_id: user.commerce_id) : scope.none
    end
  end
end
