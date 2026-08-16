class Order < ApplicationRecord
  include TableBroadcaster

  enum :status, { open: 1, closed: 2 }, default: :open

  # One-open-order-per-table is enforced by a partial unique index — see db/migrate/*_create_orders.rb.
  scope :open_for, ->(table) { open.where(table_id: table.id) }

  validates_presence_of :opened_at

  belongs_to :table, optional: false

  has_many :order_items, dependent: :destroy
  has_many :checks, dependent: :destroy

  after_create :broadcast_table
  after_destroy :broadcast_table

  # Starts from a real Money zero (not the bare Integer 0 that Enumerable#sum
  # defaults to) so this is always safe to call .format on, even with no
  # items yet.
  def total
    order_items.reduce(Money.new(0, Product::CURRENCY)) { |sum, item| sum + item.complete_item_price }
  end

  private

  def broadcast_table
    broadcast_table_update(table)
  end
end
