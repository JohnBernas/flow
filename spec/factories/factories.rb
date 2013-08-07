FactoryGirl.define do
  factory :story do
    column
  end

  factory :column do
    title { Faker::Name.title }
    limit 3
    criteria tags: 'customer1'
    board
  end

  factory :swimlane do
    title { Faker::Name.title }
    board
  end

  factory :board do
    title { Faker::Name.title }
  end
end
