class OrderItemModifier < ApplicationRecord
  monetize :price_delta_cents

  validates_presence_of :modifier_group_name
  validates_presence_of :modifier_name

  belongs_to :order_item, optional: false
end
