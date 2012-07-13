class Server < ActiveRecord::Base
  belongs_to :environment
  
  attr_accessible :datacenter, :environment_id, :description, :fqdn, :name, :priv_ip, :pub_ip, :role
  

end
