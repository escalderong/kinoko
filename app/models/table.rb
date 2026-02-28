class Table
  include Mongoid::Document
  include Mongoid::Timestamps
  include SimpleEnum::Mongoid

  field :capacity, type: Integer
  field :number, type: Integer

  as_enum :status, { available: 1, reserved: 2, occupied: 3 }

  validates_presence_of :number
  validates_presence_of :capacity
  validates_uniqueness_of :number, scope: :commerce

  belongs_to :commerce, optional: false
end
