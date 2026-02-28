class VariantGroup
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :is_required, type: Boolean, default: false

  validates_presence_of :name

  belongs_to :product, optional: false

  has_many :variants
end
