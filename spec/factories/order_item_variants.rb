FactoryBot.define do
  factory :order_item_variant do
    association :order_item
    variant_group_name { "Size" }
    variant_name { "Large" }
    price_delta { Money.new(0, "COP") }
  end
end
