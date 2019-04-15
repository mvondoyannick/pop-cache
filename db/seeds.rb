# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
Client::create_user('Test1', 'lorem', '699999991', 2514635874, 123456, 'Masulin') 
Client::create_user('Test2', 'lorem ipsum', '699999992', 2514635873, 123456, 'Feminin' )
