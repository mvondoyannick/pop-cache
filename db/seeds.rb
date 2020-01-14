# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
#Client::create_user(Faker::Name.name, Faker::FunnyName.two_word_name, '699599993', 2514635874, 123456, 'Masulin')
#Client::create_user(Faker::Name.name, Faker::FunnyName.two_word_name, '699990994', 2514665873, 123456, 'Feminin' )
customer = Customer.create(
    [
        {
            name: "MVONDO",
            second_name: "Yannick",
            phone: 691541189,
            password: 123450,
            sexe: "masculin"
        }
    ]
)
