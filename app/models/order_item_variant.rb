class OrderItemVariant
  include Mongoid::Document
  include Mongoid::Timestamps

  field :variant_group_name, type: String
  field :variant_name, type: String
  field :price_delta, type: Money, default: Money.new(0, "COP")

  validates_presence_of :variant_group_name
  validates_presence_of :variant_name

  belongs_to :order_item, optional: false
end
