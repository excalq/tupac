class Command < ActiveRecord::Base
  attr_accessible :command, :description, :name
  has_many :command_template_vars
  validates_presence_of :name
  validates_presence_of :command
  validates_uniqueness_of :name

  before_save :create_sudo_conf


  def create_sudo_conf
    
  end

  # Returns a hash of command template's variables and past values
  def get_template_variable_hash
    cmd_vars = extract_template_vars
    cmd_vars.map{|c| {c => CommandTemplateVar.get_saved_values(self, c) }}
  end

  # For commands having moustache template variables, find them and
  # create references to them in that table.
  def extract_template_vars
    return self.command.scan(/{{([a-z0-9\-_]+?)}}/i).flatten
  end

end
