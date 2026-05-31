FactoryBot.define do
  factory :order do
    association :table
    opened_at { Time.current }
    status { :open }
  end
end
