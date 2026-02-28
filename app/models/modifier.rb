class Modifier
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String

  field :price_delta, type: Money, default: Money.new(0, "COP")

  validates_presence_of :name

  belongs_to :modifier_group, optional: false
end
