class VariantGroup < ApplicationRecord
  validates_presence_of :name

  belongs_to :product, optional: false, touch: true

  has_many :variants, dependent: :destroy
end
