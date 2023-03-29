
objective = Objective.where('extract(year  from created_at) = ?', 2020).last

objective.kleerers_objectives.push [KleerersObjective.new(kleerer: Kleerer.find_by(name: 'Jenny'), has_custom_objective: false),]

# = [
#   KleerersObjective.new(kleerer: kleerer, has_custom_objective: false),
# ]

objective.save!
