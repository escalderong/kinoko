class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :rememberable, :validatable

  attribute :locale, default: -> { I18n.default_locale.to_s }

  enum :role, { owner: 0, admin: 1, waiter: 2, cashier: 3 }

  validates_presence_of :name
  validates_presence_of :role
  validates :locale, inclusion: { in: ->(_user) { I18n.available_locales.map(&:to_s) } }, allow_blank: true

  belongs_to :commerce, optional: false
end
