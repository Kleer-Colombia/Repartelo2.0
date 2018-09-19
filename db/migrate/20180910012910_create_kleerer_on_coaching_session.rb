class CreateKleererOnCoachingSession < ActiveRecord::Migration::Current
  def change
    create_join_table :kleerers, :coaching_sessions do |t|
      t.index :kleerer_id
      t.index :coaching_session_id
    end

  end

end
