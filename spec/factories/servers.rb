FactoryGirl.define do
  factory :server do
    association :enviromnent, factory: :environment
    name 'virtual test server 1'
    role 'testing'
    description 'A fake server for testing environments'
    datacenter 'none'
    status 0
  end
end

