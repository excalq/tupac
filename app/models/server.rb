class Server < ActiveRecord::Base
  attr_accessible :datacenter, :description, :fqdn, :name, :priv_ip, :pub_ip, :role, :status
end
