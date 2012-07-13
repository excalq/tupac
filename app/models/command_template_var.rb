class CommandTemplateVar < ActiveRecord::Base
  attr_accessible :command, :key, :value
  belongs_to :command

  def self.get_saved_values(command, key)
    where(:command_id => command.id, :key => key).map(&:value)
  end

end
