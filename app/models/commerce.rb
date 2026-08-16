class Commerce < ApplicationRecord
  # Curated set of daisyUI 5 themes offered by the appearance picker. This list
  # is the single source of truth for the picker and the inclusion validation,
  # and must stay in sync with the `themes:` list compiled in
  # app/assets/tailwind/application.css.
  THEMES = %w[
    light dark cupcake bumblebee emerald synthwave retro cyberpunk valentine
    halloween garden forest aqua pastel fantasy luxury dracula cmyk autumn
    business acid lemonade night coffee winter dim caramellatte abyss
  ].freeze

  DEFAULT_THEME = "light"

  validates_presence_of :name
  validates :theme, inclusion: { in: THEMES }

  has_many :product_categories, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :tables, dependent: :destroy
  has_many :users, dependent: :destroy
  has_many :floor_zones, dependent: :destroy
end
