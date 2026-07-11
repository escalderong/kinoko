class Table
  include Mongoid::Document
  include Mongoid::Timestamps
  include SimpleEnum::Mongoid

  field :capacity, type: Integer
  field :number, type: Integer
  field :pos_x,  type: Integer, default: 0
  field :pos_y,  type: Integer, default: 0
  field :width,  type: Integer, default: 2
  field :height, type: Integer, default: 2

  as_enum :status, { available: 1, reserved: 2, occupied: 3 }

  validates_presence_of :number
  validates_presence_of :capacity
  validates_uniqueness_of :number, scope: :commerce
  validates :pos_x, :pos_y, numericality: { greater_than_or_equal_to: 0 }
  validates :width, :height, numericality: { greater_than_or_equal_to: 1 }

  belongs_to :commerce, optional: false
  belongs_to :floor_zone, optional: false
end
