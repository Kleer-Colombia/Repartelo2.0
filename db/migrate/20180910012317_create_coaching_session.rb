class CreateCoachingSessions < ActiveRecord::Migration::Current
  def change
    create_table :coaching_sessions do |t|
      t.belongs_to :balance, index: true
      t.date :date, :null => false
      t.string :description, :null => false
      t.string :complementary, :null => false
      t.timestamps
    end
  end
end
