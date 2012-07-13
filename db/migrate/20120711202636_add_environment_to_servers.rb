class AddEnvironmentToServers < ActiveRecord::Migration
  def change
    add_column :servers, :environment_id, :int
  end
end
