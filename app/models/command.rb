class Command < ActiveRecord::Base
  attr_accessible :command, :description, :name, :sudo_block
end
