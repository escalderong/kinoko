class OrderItem
  include Mongoid::Document
  include Mongoid::Timestamps
  include TableBroadcaster

  field :base_price, type: Money
  field :fired_at, type: DateTime
  field :product_name, type: String
  field :quantity, type: Integer
  field :notes, type: String

  validates_presence_of :base_price
  validates_presence_of :product_name

  validates :quantity, presence: true, numericality: { greater_than: 0 }

  belongs_to :order, optional: false

  has_many :order_item_variants
  has_many :order_item_modifiers
  has_many :check_items

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
