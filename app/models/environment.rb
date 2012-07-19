class Environment < ActiveRecord::Base
  attr_accessible :description, :name, :servers_attributes
  has_many :servers
  accepts_nested_attributes_for :servers, :allow_destroy => true, :reject_if => :all_blank
end
