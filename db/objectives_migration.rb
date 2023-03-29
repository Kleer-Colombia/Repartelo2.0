
objective = Objective.where(year: 2021).last

objective.kleerers_objectives[
  KleerersObjective.new(kleerer: Kleerer.where(name: 'Jenny'), has_custom_objective: false),
]
