FactoryBot.define do
  factory :item do
    name { Faker::Name.first_name }
    description { Faker::Lorem.paragraph }
    unit_price { Faker::Number.within(range: 1..10) }
    sequence(:merchant_id)
  end
end
