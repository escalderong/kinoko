class TicketItem
  include Mongoid::Document
  include Mongoid::Timestamps

  field :quantity, type: Integer

  validates_presence_of :quantity

  belongs_to :ticket, optional: false

  embeds_one :order_item
end
