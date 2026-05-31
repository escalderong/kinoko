FactoryBot.define do
  factory :modifier_group do
    association :product
    name { "Extras" }
    is_required { false }
    min_selected { 0 }
    max_selected { nil }
  end
end
