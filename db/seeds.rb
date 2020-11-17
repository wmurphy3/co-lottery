# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Prize.create([
  { name: '5 lb Gummy Bear', probability: 10, class_name: 'gummy' },
  { name: 'Blow Up Yard Decorations', probability: 10, class_name: 'blow_up' },
  { name: 'Burrito Blanket', probability: 10, class_name: 'blanket' },
  { name: 'Colorado-shaped Cutting Board', probability: 10, class_name: 'cutting_board' },
  { name: 'Yeti Cooler', probability: 10, class_name: 'cooler' },
  { name: 'Noise Cancelling Headphones', probability: 10, class_name: 'headphones' },
  { name: 'Air Fryer', probability: 10, class_name: 'fryer' },
  { name: 'Tacky Holiday Sweater', probability: 10, class_name: 'sweater' },
  { name: 'Amazon Gift Card', probability: 10, class_name: 'gift_card' },
  { name: 'Desktop Waffle Maker', probability: 10, class_name: 'waffle_maker' }
])