class CommandsController < ApplicationController


  def index
    # TODO: check ACL - SysAdmins only here
    @commands = Command.all

  end

  # Define new commands
  def new
    # TODO: check ACL - SysAdmins only here
    @command = Command.new(params[:command])
    render :edit
  end

  # Create command entry. On success, displays a sudoers config block for the sysadmin.
  def create
    params[:command].delete :sudo_block # Discard non-editable form fields
    @command = Command.new(params[:command])
    if @command.save
      @update_sudo = true # Trigger display of instructions for updating sudoers conf
      flash.now[:notice] = "Command successfully created."
    else
      flash.now[:error] = @command.errors.full_messages.join('. ')
    end
    render :edit
  end

  def show
  end

  def edit
    # TODO: Check ACL - SysAdmins only
    @command = Command.find(params[:id])
  end

  def update
    # TODO: Check ACL - SysAdmins only
    params[:command].delete :sudo_block # Discard non-editable form fields
    @command = Command.find(params[:id])
    @command.update_attributes(params[:command])
    if @command.save
      @update_sudo = true # Trigger display of instructions for updating sudoers conf
      flash.now[:notice] = "Command \"#{@command.name}\" successfully updated."
    else
      flash.now[:error] = @user.errors.full_messages.join('. ')
      @errors = @command.errors
    end
    render :edit
  end

  def delete
    # TODO: Check ACL - SysAdmins only
  end

  # Issuing a command on the target environment
  def run_command
    # TODO: Check ACL - SysAdmins and Deployers only

    # TODO: validate servers are in user.group.acl_rules
    # TODO: validates servers are online
    # TODO: validates command arguments from user (if present)
    # TODO: Run commands on all servers (looped shelling)
    #   store as results = [{:server => "serverA", :returned, :output, :error}, ...}
    #
    environment = Environment.find_by_name(params[:environment]) # TODO: ACL check
    command = Command.find(params[:id])
    # --- AJAX Request to run a specific command/deployment
    #if request.xhr? and params[:run_command].present?
      variables = params[:variables] || {}
      servers = environment.servers.where("name IN (?)", params[:servers]).all # TODO: ACL check

      result_set = []
      result = command.run_command(servers, variables)
      result_set << result
      all_successful = (result_set.map{|s| s[:status]}.inject(:&) == 0)
      all_failed = (result_set.map{|s| s[:status]}.inject(:&) != 0)
      if all_successful
        message = "All commands were run successfully. The log is displayed below."
      elsif all_failed
        message = "All commands failed. The tupac system or network configuration might be setup incorrectly."
      else
        message = "Some commands were run successfully, and some failed. The logs below show details."
      end
    #end

    # Temporary prettier logging
    result_set.each do |r|
      r[:log_text].gsub!("\n", "<br />") if r[:log_text].present?
    end
    logger.error "+++++++++++#{result_set.inspect}"
    render :json => result_set
  end

  def run_deployment
    # TODO: Check ACL - SysAdmins and Deployers only

    # TODO: validate servers are in user.group.acl_rules
    # TODO: validates servers are online
    # TODO: validates command arguments from user (if present)
    # TODO: Run commands on all servers (looped shelling)
    #   store as results = [{:server => "serverA", :returned, :output, :error}, ...}
    #

  end


  # --- AJAX methods

  def get_command
    if params[:id] and @command = Command.find(params[:id]) # TODO: ACL check for group access
      render :json => {:data => @command.command}
    end
  end

  # Retreive list of variables present in selected command template and their saved values
  # Skips certain special variables like 'date' and 'servers'
  def get_variables
    if params[:id] and @command = Command.find(params[:id]) # TODO: ACL check for group access
      vars = @command.get_template_variable_hash
      render :json => {:data => vars}
    else
      render :json => {:error => "Unable to find requested command."}
    end
  end

end
