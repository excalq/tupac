class CreateCommands < ActiveRecord::Migration
  def change
    create_table :commands do |t|
      t.string :name
      t.text :command
      t.text :sudo_block
      t.text :description

      t.timestamps
    end
  end
end
