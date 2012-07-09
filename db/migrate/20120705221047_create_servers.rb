class CreateServers < ActiveRecord::Migration
  def change
    create_table :servers do |t|
      t.string :name
      t.string :role
      t.text :description
      t.string :datacenter
      t.integer :status
      t.string :pub_ip
      t.string :priv_ip
      t.string :fqdn

      t.timestamps
    end
  end
end
