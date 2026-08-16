class Variant < ApplicationRecord
  monetize :price_delta_cents

  validates_presence_of :name
  validates_presence_of :sku
  validate :price_delta_within_base_price

  belongs_to :variant_group, optional: false, touch: true

  private

  def price_delta_within_base_price
    return unless price_delta&.negative?

    base_price = variant_group&.product&.base_price
    errors.add(:price_delta, :exceeds_base_price) if base_price && price_delta.abs > base_price
  end
end
