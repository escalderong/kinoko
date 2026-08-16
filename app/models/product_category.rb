class ProductCategory < ApplicationRecord
  # Curated set of Font Awesome solid slugs offered by the category icon picker.
  # This list is the single source of truth for the picker and the inclusion
  # validation. Slugs are rendered by IconsHelper#icon as `fa-solid fa-<slug>`.
  ICONS = %w[
    utensils burger pizza-slice hotdog drumstick-bite bowl-food bowl-rice
    plate-wheat bread-slice cheese egg fish shrimp carrot pepper-hot
    apple-whole lemon ice-cream cake-candles cookie mug-hot mug-saucer
    wine-glass martini-glass beer-mug-empty bottle-water blender jar
  ].freeze

  validates_presence_of :name
  validates_presence_of :icon
  validates :name, uniqueness: { scope: :commerce_id }
  validates :icon, inclusion: { in: ICONS }

  belongs_to :commerce, optional: false, touch: true

  has_many :products, dependent: :restrict_with_error
end
