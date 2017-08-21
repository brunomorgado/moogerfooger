FactoryGirl.define do
  factory :definition, class: Mooger::Definition do
    moogs []
    initialize_with { new(moogs) }
  end
end
