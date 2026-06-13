class CommercePolicy < ApplicationPolicy
  # Settings & user management are owner-only.
  def settings?     = owner?
  def manage_users? = owner?

  def update? = owner?
  def edit?   = update?

  private

  def owner?
    user.present? && user.owner?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      # A user only ever sees their own commerce.
      scope.where(id: user.commerce_id)
    end
  end
end
