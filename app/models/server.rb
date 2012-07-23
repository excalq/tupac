class Server < ActiveRecord::Base
  belongs_to :environment

  attr_accessible :datacenter, :environment_id, :description, :fqdn, :name, :priv_ip, :pub_ip, :role

  validates_presence_of :name, :role
  validate :network_access_path
 
  HUMANIZED_ATTRIBUTES = {
    :pub_ip => "Public IP Address",
    :fqdn => "Full DNS Address/Name",
    :priv_ip => "Private IP Address"
  }

  def network_access_path
    if pub_ip.blank? and fqdn.blank?
      errors.add(:pub_ip, " or Full DNS Address/Name must be provided.")
      errors.add(:fqdn, " or Public IP Address must be provided.")
      return false
    end
  end

  # TODO: damn thing doesn't work (validation errors aren't using human field names)
  def self.human_attribute_name(attr, options={})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

end
