class Check < ApplicationRecord
  monetize :subtotal_cents, :tax_cents, :tip_cents

  enum :status, { open: 1, paid: 2 }, default: :open

  belongs_to :order, optional: false

  has_many :check_items, dependent: :destroy

  def total
    subtotal + tax + tip
  end
end
