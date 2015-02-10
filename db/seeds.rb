# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

TRACKED_AUTHOR_IDS =  [1, 2, 6, 7, 8, 1110, 2323, 14349, 14849, 15645, 15655, 15737, 17666, 19388, 22712, 22717, 22790, 23261, 24195, 24222, 24701, 25094, 25095, 25591, 26549, 26755, 26966, 27713, 27895, 29088, 31252, 31307, 31348, 31354, 31484, 31810, 31870, 32114, 32348, 32350, 32352, 32382, 32385, 32574, 32802, 32835, 33100, 33683, 34587, 34604, 35599, 47159, 55959, 78894]

TRACKED_AUTHOR_IDS.each do |ff_id|
  Author.create(forum_id: ff_id)
end