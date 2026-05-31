FactoryBot.define do
  factory :check do
    association :order
    subtotal { Money.new(0, "COP") }
    tax { Money.new(0, "COP") }
    tip { Money.new(0, "COP") }
    status { :open }
  end
end
