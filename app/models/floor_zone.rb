class FloorZone < ApplicationRecord
  validates_presence_of :name

  belongs_to :commerce, optional: false
  has_many :tables, dependent: :destroy

  # Grid X for a newly added table: just past the rightmost existing one, so
  # new tables never spawn on top of each other.
  def next_table_x
    tables.pluck(:pos_x, :width).map { |x, w| x.to_i + w.to_i }.max || 0
  end
end
