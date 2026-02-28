class OrderItem
  include Mongoid::Document
  include Mongoid::Timestamps

  field :base_price, type: Money
  field :fired_at, type: DateTime
  field :product_name, type: String
  field :quantity, type: Integer
  field :notes, type: String

  validates_presence_of :base_price
  validates_presence_of :product_name
  validates_presence_of :quantity

  belongs_to :order, optional: false

  has_many :order_item_variants
  has_many :order_item_modifiers

  embedded_in :ticket_item
end
