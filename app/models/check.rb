class Check
  include Mongoid::Document
  include Mongoid::Timestamps
  include SimpleEnum::Mongoid

  field :subtotal, type: Money, default: Money.new(0, "COP")
  field :tax, type: Money, default: Money.new(0, "COP")
  field :tip, type: Money, default: Money.new(0, "COP")

  as_enum :status, { open: 1, paid: 2 }

  belongs_to :order, optional: false

  def total
    subtotal + tax + tip
  end
end
