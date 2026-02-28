class OrderItemModifier
  include Mongoid::Document
  include Mongoid::Timestamps

  field :modifier_group_name, type: String
  field :modifier_name, type: String
  field :price_delta, type: Money, default: Money.new(0, "COP")

  validates_presence_of :modifier_group_name
  validates_presence_of :modifier_name

  belongs_to :order_item, optional: false
end
