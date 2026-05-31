FactoryBot.define do
  factory :variant do
    association :variant_group
    name { "Large" }
    sequence(:sku) { |n| "SKU-#{n}" }
    price_delta { Money.new(0, "COP") }
  end
end
