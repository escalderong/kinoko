FactoryBot.define do
  factory :table do
    association :commerce
    sequence(:number) { |n| n }
    capacity { 4 }
    status { :available }
  end
end
