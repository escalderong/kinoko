FactoryBot.define do
  factory :table do
    association :commerce
    floor_zone { association :floor_zone, commerce: commerce }
    sequence(:number) { |n| n }
    capacity { 4 }
    status { :available }
    pos_x { 0 }
    pos_y { 0 }
    width { 2 }
    height { 2 }
  end
end
