FactoryBot.define do
  factory :product_category do
    association :commerce
    name { "Main Dishes" }
    icon { "utensils" }
  end
end
