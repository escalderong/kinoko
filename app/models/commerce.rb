class Commerce
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String

  validates_presence_of :name

  has_many :product_categories
  has_many :tables
  has_many :users
end
