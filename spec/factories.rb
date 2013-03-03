FactoryGirl.define do

  factory :user do
    sequence(:email) {|n| "user#{n}@indeos.es"}
    password 'secret'
  end

  factory :admin, parent: :user  do
    admin true
  end

end
