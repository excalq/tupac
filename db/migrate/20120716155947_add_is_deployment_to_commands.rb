class AddIsDeploymentToCommands < ActiveRecord::Migration
  def change
    add_column :commands, :is_deployment, :boolean
  end
end
