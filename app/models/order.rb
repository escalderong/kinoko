class Order
  include Mongoid::Document
  include Mongoid::Timestamps

  field :opened_at, type: DateTime
  field :closed_at, type: DateTime

  enum status: { open: 1, closed: 2 }, default: :open

  validates_presence_of :opened_at

  belongs_to :table, optional: false

  has_many :order_items
  has_many :tickets
end
