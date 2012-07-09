class CreateAclRules < ActiveRecord::Migration
  def change
    create_table :acl_rules do |t|
      t.string :name
      t.text :description
      t.integer :group
      t.string :accessible_type
      t.string :accessible_identifier

      t.timestamps
    end

    add_index :acl_rules, :name
    add_index :acl_rules, :group
    add_index :acl_rules, :accessible_type
  end

end
