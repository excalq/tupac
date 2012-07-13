class CommandTemplateVars < ActiveRecord::Migration
  def change
    create_table 'command_template_vars' do |t|
      t.references :command
      t.column :key, :string
      t.column :value, :string
      t.references :acl_group
      t.timestamps
    end

    add_index :command_template_vars, [:command_id, :acl_group_id]
    add_index :command_template_vars, :key
    add_index :command_template_vars, :acl_group_id
  end
end
