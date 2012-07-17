class RemoveNullFromCommandsIsDescription < ActiveRecord::Migration
  def change
    change_column :commands, :is_deployment, :boolean, :null => false, :default => false
  end
end
