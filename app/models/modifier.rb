class Modifier
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String

  field :price_delta, type: Money, default: Money.new(0, "COP")
  field :is_active, type: Boolean, default: true

  validates_presence_of :name
  validate :price_delta_within_base_price

  belongs_to :modifier_group, optional: false

  private

  def price_delta_within_base_price
    return unless price_delta&.negative?

    base_price = modifier_group&.product&.base_price
    errors.add(:price_delta, :exceeds_base_price) if base_price && price_delta.abs > base_price
  end
end
