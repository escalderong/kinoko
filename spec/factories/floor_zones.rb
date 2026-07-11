FactoryBot.define do
  factory :floor_zone do
    association :commerce
    sequence(:name) { |n| "Zone #{n}" }
    position { 0 }
  end
end
