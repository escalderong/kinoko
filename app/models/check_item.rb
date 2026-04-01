class CheckItem
  include Mongoid::Document
  include Mongoid::Timestamps

  field :quantity, type: Integer

  validates :quantity, presence: true, numericality: { greater_than: 0 }

  belongs_to :check, optional: false
  belongs_to :order_item, optional: false

  delegate :complete_item_price, to: :order_item
end
