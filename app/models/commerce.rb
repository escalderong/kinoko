class Commerce
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :theme, type: String, default: "light"

  validates_presence_of :name

  has_many :product_categories
  has_many :tables
  has_many :users
  has_many :floor_zones
end
