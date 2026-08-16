class ModifierGroup < ApplicationRecord
  validates_presence_of :name

  belongs_to :product, optional: false, touch: true

  has_many :modifiers, dependent: :destroy
end
