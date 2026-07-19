FactoryBot.define do
  factory :product do
    association :commerce
    association :product_category
    name { "Burger" }
    base_price { Money.new(10_000, "COP") }
    is_active { true }
  end
end
