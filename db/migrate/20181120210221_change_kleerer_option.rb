class ChangeKleererOption < ActiveRecord::Migration[5.2]
  def change

    rename_column :kleerers, :option, :opt

    change_table :kleerers do |t|
      t.belongs_to :option
    end

    Kleerer.all.each do |kleerer|
      Option.all.each do  |option|
        if kleerer.opt == option.name
          kleerer.option = option
          kleerer.save!
        end
      end
    end

    remove_column :kleerers, :opt, :string

  end
end
