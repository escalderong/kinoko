FactoryBot.define do
  factory :order_item_modifier do
    association :order_item
    modifier_group_name { "Extras" }
    modifier_name { "Extra cheese" }
    price_delta { Money.new(0, "COP") }
  end
end
