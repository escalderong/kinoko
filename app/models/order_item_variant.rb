class OrderItemVariant < ApplicationRecord
  monetize :price_delta_cents

  validates_presence_of :variant_group_name
  validates_presence_of :variant_name

  belongs_to :order_item, optional: false
end
