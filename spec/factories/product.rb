FactoryBot.define do
  factory :product do
    name { "Product #{rand(100)}" }
    price { rand(1.0..100.0).round(2) }
  end
end
