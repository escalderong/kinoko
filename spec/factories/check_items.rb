FactoryBot.define do
  factory :check_item do
    association :check
    association :order_item
    quantity { 1 }
  end
end
