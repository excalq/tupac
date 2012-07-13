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
      flash.now[:notice] = "Command successfully created. Now <a href=\"#update-sudoers\">update your sudoers config</a>."
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
    unless @command.save
      flash.now[:error] = @user.errors.full_messages.join('. ')
      @errors = @command.errors
    else
      flash.now[:notice] = "Command \"#{@command.name}\" successfully updated. Now <a href=\"#update-sudoers\">update your sudoers config</a>."
    end
    render :edit
  end

  def delete
    # TODO: Check ACL - SysAdmins only
  end

  def perform
    # TODO: Check ACL - SysAdmins and Deployers only

    # TODO: validate servers are in user.group.acl_rules
    # TODO: validates servers are online
    # TODO: validates command arguments from user (if present)
    # TODO: Run commands on all servers (looped shelling)
    #   store as results = [{:server => "serverA", :returned, :output, :error}, ...}
    #
    @environment = Environment.find_by_name(params[:environment])
    @servers = @environment.servers # TODO: ACL check
    @commands = Command.order("created_at DESC").collect {|c| [c.name, c.id]} # TODO: Commands allowed to acl_group
  
    if params[:run_command].present?
      
      results = []
      dummy_command_result = {:server => "server_1", :returned => 0, :output => "[2012-10-01 09:30:00] Command foo is running...\n  [2012-10-01 09:30:00] Command foo complete.", :error => "[WARN] Could not read file permissions."}
      results << dummy_command_result
      # TODO: Save log of command output
      all_successful = (results.map{|s| s[:returned]}.inject(:&) == 0)
      all_failed = (results.map{|s| s[:returned]}.inject(:&) != 0)
      if all_successful
        flash.now[:notice] = "All commands were run successfully. The log is displayed below."
      elsif all_failed
        flash.now[:notice] = "All commands failed. The tupac system or network configuration might be setup incorrectly."
      else 
        flash.now[:notice] = "Some commands were run successfully, and some failed. The logs below show details."
      end
    end
  end

  # --- AJAX methods

  # Retreive list of variables present in selected command template and their saved values
  def get_variables
    if params[:id] and @command = Command.find(params[:id]) # TODO: ACL check for group access
      vars = @command.get_template_variable_hash
      render :json => {:data => vars}
    else
      render :json => {:error => "Unable to find requested command."}
    end
  end

end
