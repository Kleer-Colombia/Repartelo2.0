class CreateKleererOnCoachingSession < ActiveRecord::Migration[5.1]
  def change
    create_table :kleerer_on_coaching_sessions, id: false do |t|
      t.belongs_to :kleerers, index: true
      t.belongs_to :coaching_sessions, index: true
    end

  end
end
