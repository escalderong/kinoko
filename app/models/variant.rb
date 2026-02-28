class Variant
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :sku, type: String
  field :price_delta, type: Money, default: Money.new(0, "COP")

  validates_presence_of :name
  validates_presence_of :sku

  belongs_to :variant_group, optional: false
end
