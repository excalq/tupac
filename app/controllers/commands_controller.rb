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
    @command = Command.new(params[:command])
    unless @command.save
      flash[:error] = @user.errors.full_messages.join('. ')
      @errors = @command.errors
    else
      flash[:notice] = "Command successfully created. Now <a href=\"#update-sudoers\">update your sudoers config</a>."
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
