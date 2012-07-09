class AclRules < ActiveRecord::Base
  attr_accessible :accessible_identifier, :accessible_type, :description, :group, :name
end
