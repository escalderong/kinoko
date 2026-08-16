class Table < ApplicationRecord
  enum :status, { available: 1, reserved: 2, occupied: 3 }, default: :available

  validates_presence_of :number
  validates_presence_of :capacity
  validates :number, uniqueness: { scope: :commerce_id }
  validates :pos_x, :pos_y, numericality: { greater_than_or_equal_to: 0 }
  validates :width, :height, numericality: { greater_than_or_equal_to: 1 }

  belongs_to :commerce, optional: false
  belongs_to :floor_zone, optional: false

  has_many :orders, dependent: :restrict_with_error
end
