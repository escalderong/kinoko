class ModifierGroup
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :is_required, type: Boolean, default: false
  field :min_selected, type: Integer, default: 0
  field :max_selected, type: Integer

  validates_presence_of :name

  belongs_to :product, optional: false

  has_many :modifiers
end
