class CommercePolicy < ApplicationPolicy
  # Settings & user management are owner-only.
  def settings?     = owner?
  def manage_users? = owner?

  def update? = owner?
  def edit?   = update?

  def view_orders?   = user.present?
  def view_products? = user.present? && (user.owner? || user.admin?)

  private

  def owner?
    user.present? && user.owner?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      # A user only ever sees their own commerce.
      user.present? ? scope.where(id: user.commerce_id) : scope.none
    end
  end
end
