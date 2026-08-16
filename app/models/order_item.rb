class OrderItem < ApplicationRecord
  include TableBroadcaster

  monetize :base_price_cents, allow_nil: true

  validates_presence_of :base_price
  validates_presence_of :product_name

  validates :quantity, presence: true, numericality: { greater_than: 0 }

  belongs_to :order, optional: false

  has_many :order_item_variants, dependent: :destroy
  has_many :order_item_modifiers, dependent: :destroy
  has_many :check_items, dependent: :destroy

  after_create :broadcast_table
  after_destroy :broadcast_table

  def complete_item_price
    base_price + order_item_variants.sum(&:price_delta) + order_item_modifiers.sum(&:price_delta)
  end

  private

  # Goes through order.table rather than a memoized table reference on self —
  # an OrderItem has no direct table association, only its parent order does.
  def broadcast_table
    broadcast_table_update(order.table)
  end
end
