FactoryBot.define do
  factory :variant_group do
    association :product
    name { "Size" }
    is_required { false }
  end
end
