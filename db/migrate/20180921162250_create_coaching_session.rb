class CreateCoachingSession < ActiveRecord::Migration[5.2]
  def change
    create_table :coaching_sessions do |t|
      t.belongs_to :balance, index: true
      t.date :date, :null => false
      t.string :description, :null => false
      t.string :complementary
      t.timestamps
    end
  end
end

