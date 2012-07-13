class Environment < ActiveRecord::Base
  attr_accessible :description, :name
  has_many :servers
  accepts_nested_attributes_for :servers

  # For fields_for on environment#show view
  def servers_attributes=(attributes) 

  end
end
