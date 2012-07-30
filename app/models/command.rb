require "open4"

class Command < ActiveRecord::Base
  attr_accessible :command, :description, :is_deployment, :name
  has_many :command_template_vars
  has_many :log_entries
  validates_presence_of :name
  validates_presence_of :command
  validates_uniqueness_of :name
  validate :validate_command_path

  before_save :sanitize_command
  after_save :set_sudo_block

  def sanitize_command
    self.command = self.command.gsub("\n", "") # Remove new lines
  end

  # Validates that the requested command exists, and sets full path if necessary.
  def validate_command_path
    command = self.command
    # TODO/REFACTOR: We're finding the command using everything until the first space. Kind of lame...
    command_executable = command.match(/(^[^\s]+)/).try(:[], 1) # Get the name of the actual command
    unless command_executable.present?
      errors.add(:command, "must contain a valid, executable system command.")
      return false
    end

    cmd_abs_path = `which #{command_executable}`.chomp # Check for existance in executable path, get full path
    unless $?.to_i == 0
      errors.add(:command, "must contain a valid, executable system command.")
      return false
    end

    if cmd_abs_path == command_executable
      return true
    else
      # TODO/REFACTOR: We're finding the command using everything until the first space. Kind of lame...
      self.command = command.sub(/(^[^\s]+)/, cmd_abs_path); # Replace command with full-path command
      return true
    end
  end

  def set_sudo_block 
    self.update_column(:sudo_block, generate_sudo_block)
  end

  # Creates a comment and a line of config to add to /etc/sudoers.d/tupac
  def generate_sudo_block
    # This would be better if sudoers allowed regex and repetition rather than simple shell globs like "*"
    command = self.command.gsub(/([\\\:*?,\(\)\[\]!=])/m, '\\\\\1') # escape sudo's special chars
    # {{date}} becomes a UTC iso-8601 datetime, like 2012-07-18 15:00
    command = command.gsub(/{{date}}/, '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9]') # yyyy-mmm-dd HH-mm-ss
    command = command.gsub(/{{.*?}}/, '[A-z]*') # sadly this is equivalent to /[A-z].*/ in sudoers
    command = command.gsub(/["']/, '')
    config_line = "# -- #{self.name} --\nCmnd_Alias       TCOMMAND_#{self.id} = #{command}"
    config_line
  end

  def run_command(servers, variables, environment)
    user = nil # TODO - ACL check for user
    # TODO: Sanity check : ensure servers are in this environment
    event_type = (self.is_deployment) ? 'deployment' : 'command'
    server_names = servers.map(&:name)
    variables = variables.merge({:servers => server_names})
    command_text = generate_command_from_template(variables, environment)

    command = "sudo -n -u #{Tupac::Application.config.invoking_user} #{command_text}"
    #command = "#{command_text}" # TESTING - non-sudo

    require 'shellrunner'

    runnable = ShellRunner.new(command)
    runnable.run
    exitstatus = runnable.exitstatus.to_i
    output = runnable.output.join("\n")
    error = runnable.error.join("\n")


    # Handle error cases:
      # 1. Program ran and returned successfully (returned 0)
      # 2. Program ran and did not return 0
      # 3. Command did not exist
      # 4. Sudo did not allow the command (asked for password)
    case exitstatus
    when 0
      status_message = "The command ran successfully."
    else
      if (error.include? "sudo: sorry, a password is required to run sudo")
        status_message = "The command was not recognized by sudo. Please see the <a href=\"/commands/#{self.id}/sudo_config_instructions\" target=\"_new\">sudo config instructions."
      elsif (error.include? ": not found" or error.include? ": command not found")
        status_message = "The command path could not be found. Please check the command settings and ensure all target servers have the requested command available."
      else
        status_message = "The command exited with a problem reported. Check the error log for details."
      end
    end

    log_text = "---------- COMMAND EXECUTED: ---------\n\n" + command + "\n\n---------- Output: ---------\n\n" + output.to_s + "\n\n---------- ERRORS: ---------\n\n" + error.to_s
    result = {:event_type => event_type, :output => output, :error => error, :status => exitstatus, :status_message => status_message, :log_text => log_text}
    log_entry = LogEntry.create(:command => self, :event_type => event_type, :result => result[:status], :log_text => log_text, :user => user)
    return result
  end

  # Returns a hash of command template's variables and past values (Is used for div.command_variables AJAX)
  def get_template_variable_hash
    # Some variables are handled specially with their own UI elements, omit these here.
    excludes = ['date', 'server', 'servers']
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

    # Create a runnable command by filling in all variables
    def generate_command_from_template(variables, environment)
      ctext = self.command
      # Fill in {{date}}
      ctext.gsub!('{{date}}', Time.now.utc.to_s(:db))
      # convert "{{server}}" to {{servers}} for consistency and multiple compatibility
      ctext.gsub!(/{{server(:[^\}]+)*?}}/, '{{servers\1}}')

      servers_data = []
      if variables[:servers].present?
        variables[:servers].each do |s|
          logger.error "+++++++++++# #{s}"
          servers_data << Server.find_by_name(s)
        end
        logger.error "+++++++++++ #{servers_data}"
      end

      variables.each do |key,value|
        key = key.to_s
        # Fill in server attributes
        if key = 'servers'
          ctext.gsub!('{{servers}}', servers_data.map{|s| s[:name]}.join(','))
          ctext.gsub!('{{servers:name}}', servers_data.map{|s| s[:name]}.join(','))
          ctext.gsub!('{{servers:dns}}', servers_data.map{|s| s[:fqdn]}.join(','))
          ctext.gsub!('{{servers:pub_ip}}', servers_data.map{|s| s[:pub_ip]}.join(','))
          ctext.gsub!('{{servers:priv_ip}}', servers_data.map{|s| s[:priv_ip]}.join(','))
        else
          ctext.gsub!("{{#{key}}}", value.to_s)
        end
      end
      ctext
    end

end
