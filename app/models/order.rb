class Order
  include Mongoid::Document
  include Mongoid::Timestamps
  include SimpleEnum::Mongoid

  field :opened_at, type: DateTime
  field :closed_at, type: DateTime

  as_enum :status, { open: 1, closed: 2 }, field: { default: 1 }

  validates_presence_of :opened_at

  belongs_to :table, optional: false

  has_many :order_items
  has_many :checks
end
