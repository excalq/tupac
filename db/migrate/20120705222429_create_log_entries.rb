class CreateLogEntries < ActiveRecord::Migration
  def change
    create_table :log_entries do |t|
      t.string :event_type
      t.integer :result
      t.text :log_text
      t.references :command
      t.references :user

      t.timestamps
    end
    add_index :log_entries, :command_id
    add_index :log_entries, :user_id
  end
end
