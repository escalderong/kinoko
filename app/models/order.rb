class Order
  include Mongoid::Document
  include Mongoid::Timestamps
  include SimpleEnum::Mongoid
  include TableBroadcaster

  field :opened_at, type: DateTime
  field :closed_at, type: DateTime

  as_enum :status, { open: 1, closed: 2 }, field: { default: 1 }

  scope :open, -> { where(status_cd: statuses[:open]) }
  scope :open_for, ->(table) { open.where(table_id: table.id) }

  # Enforces "at most one open order per table" atomically at the database
  # level. The app-level guard (`Order.open_for(table).exists?` in
  # OrdersController#create) is a TOCTOU race on its own — two requests can
  # both pass that check before either saves. This partial unique index (only
  # applies to documents matching status_cd: open) is what actually closes
  # the race; a second concurrent insert fails with a duplicate-key error,
  # which the controller catches and turns into the same "already_open" flash.
  index({ table_id: 1 }, { unique: true, partial_filter_expression: { status_cd: 1 } })

  validates_presence_of :opened_at

  belongs_to :table, optional: false

  has_many :order_items
  has_many :checks

  after_create :broadcast_table
  after_destroy :broadcast_table

  # Starts from a real Money zero (not the bare Integer 0 that Enumerable#sum
  # defaults to) so this is always safe to call .format on, even with no
  # items yet.
  def total
    order_items.reduce(Money.new(0, Product::CURRENCY)) { |sum, item| sum + item.complete_item_price }
  end

  private

  def broadcast_table
    broadcast_table_update(table)
  end
end
