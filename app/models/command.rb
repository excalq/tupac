class Command < ActiveRecord::Base
  attr_accessible :command, :description, :name
  has_many :command_template_vars
  validates_presence_of :name
  validates_presence_of :command
  validates_uniqueness_of :name

  before_save :create_sudo_conf


  # For commands having moustache template variables, find them and
  # create references to them in that table.
  def extract_template_vars(command)

  end

  def create_sudo_conf
    
  end

end
