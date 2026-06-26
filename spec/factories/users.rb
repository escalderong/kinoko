FactoryBot.define do
  factory :user do
    association :commerce
    name { "John Doe" }
    email { "john@example.com" }
    password { "password123" }
    role { :owner }

    trait :waiter do
      role { :waiter }
    end

    trait :admin do
      role { :admin }
    end
  end
end
