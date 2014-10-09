# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

TRACKED_AUTHOR_IDS = [1,2,6,7,14349,14849,15645,15655,17666,22712,24222,25094,25095,
                      26549,26755,26966,27895,31252,31348,31484,32310,32348,32574,
                      32352,25591,2323,26966,31252,27713,1110,47159,15737,31307,33683,
                      34604]

TRACKED_AUTHOR_IDS.each do |ff_id|
  Author.create(forum_id: ff_id)
end