require "open4"

class Command < ActiveRecord::Base
  attr_accessible :command, :description, :is_deployment, :name
  has_many :command_template_vars
  has_many :log_entries
  validates_presence_of :name
  validates_presence_of :command
  validates_uniqueness_of :name

  after_save :set_sudo_block

  def set_sudo_block 
    self.sudo_block = generate_sudo_block
  end

  # Creates the block of config to add to the 
  def generate_sudo_block
    # This would be better if sudoers allowed regex and repetition rather than simple shell globs like "*"
    command = self.command.gsub(/{{.*?}}/, '[A-z]*') # sadly this is equivalent to /[A-z].*/ in sudoers
    config_line = "Cmnd_Alias      TCOMMAND_#{self.id} = #{command}"
    config_line
  end

  def run_command(servers, variables)
  logger.error "---- #{servers.inspect} #{variables.inspect}"
    user = nil # TODO
    event_type = (self.is_deployment) ? 'deployment' : 'command'
    server_names = servers.map(&:name)
    variables = variables.merge({:servers => server_names})
    command_text = get_templated_command(variables)

    #command = "sudo -u #{Tupac::Application.config.invoking_user} #{command_text}"
command = "#{command_text}"

    require 'shellrunner'

    runnable = ShellRunner.new(command)
    runnable.run
    exitstatus = runnable.exitstatus
    output = runnable.output
    error = runnable.error

#    stdout = ""
#    stderr = ""
#    Open4::popen4(command) do |stdout, stderr, stdin| end
#    status = $?.exitstatus
    result = {:event_type => event_type, :stdout => output, :stderr => error, :status => exitstatus}
    log_text = "---------- COMMAND EXECUTED: ---------\n\n" + command + "\n\n---------- Output: ---------\n\n" + result[:stdout].to_s + "\n\n---------- ERRORS: ---------\n\n" + result[:stderr].to_s
    log_entry = LogEntry.create(:command => self, :event_type => event_type, :result => result[:status], :log_text => log_text, :user => user)
    return log_entry
  end

  # Returns a hash of command template's variables and past values (Is used for div.command_variables AJAX)
  def get_template_variable_hash
    # Some variables are handled specially with their own UI elements, omit these here.
    excludes = ['server', 'servers']
    cmd_vars = extract_template_vars
    cmd_vars.reject!{|v| excludes.include? v}
    cmd_vars.map!{|c| {c => CommandTemplateVar.get_saved_values(self, c) }}
  end

  private

    # For commands having moustache template variables, find them and
    # create references to them in that table.
    def extract_template_vars
      return self.command.scan(/{{([a-z0-9\-_]+?)}}/i).flatten
    end

    def get_templated_command(variables)
      ctext = self.command
      # convert "{{server}}" to {{servers}} for consistency and multiple compatibility
      ctext.gsub!('{{server}}', '{{servers}}')
      variables.each do |key,value|
        key = key.to_s
        value = value.join(',') if (key == "servers")
        ctext.gsub!("{{#{key}}}", value.to_s)
      end
      logger.error "------! #{ctext}"
      ctext
    end

end
