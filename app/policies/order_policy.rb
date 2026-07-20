class OrderPolicy < ApplicationPolicy
  def create?   = user.present? && (user.owner? || user.admin? || user.waiter?)
  def checkout? = user.present? && (user.owner? || user.admin? || user.cashier?)
end
