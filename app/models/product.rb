class Product
  include Mongoid::Document
  include Mongoid::Timestamps

  # Currency used for money fields until per-commerce currency is introduced.
  CURRENCY = "COP".freeze

  field :name, type: String
  field :is_active, type: Boolean, default: true
  field :base_price, type: Money

  validates_presence_of :name
  validates_presence_of :base_price

  belongs_to :commerce, optional: false
  belongs_to :product_category, optional: false

  has_many :variant_groups
  has_many :modifier_groups
end
