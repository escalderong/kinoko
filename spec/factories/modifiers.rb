FactoryBot.define do
  factory :modifier do
    association :modifier_group
    name { "Extra cheese" }
    price_delta { Money.new(0, "COP") }
    is_active { true }
  end
end
