class Product < ApplicationRecord
  # Currency used for money fields until per-commerce currency is introduced.
  CURRENCY = "COP".freeze

  monetize :base_price_cents, allow_nil: true

  validates_presence_of :name
  validates_presence_of :base_price

  belongs_to :commerce, optional: false, touch: true
  belongs_to :product_category, optional: false

  has_many :variant_groups, dependent: :destroy
  has_many :modifier_groups, dependent: :destroy
end
