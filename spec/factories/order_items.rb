FactoryBot.define do
  factory :order_item do
    association :order
    product_name { "Burger" }
    base_price { Money.new(10_000, "COP") }
    quantity { 1 }
  end
end
