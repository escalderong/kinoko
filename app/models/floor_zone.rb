class FloorZone
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,     type: String
  field :position, type: Integer, default: 0

  validates_presence_of :name

  belongs_to :commerce, optional: false
  has_many :tables, dependent: :destroy

  # Grid X for a newly added table: just past the rightmost existing one, so
  # new tables never spawn on top of each other.
  def next_table_x
    tables.only(:pos_x, :width).map { |table| table.pos_x.to_i + table.width.to_i }.max || 0
  end
end
