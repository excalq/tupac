class EnvironmentsController < ApplicationController

  def index
    # TODO - ACL - get Environments for user..
    @environments = Environment.all
  end

  def show
    if params[:key].present? && params[:key] == :name
      @environment = Environment.find_by_name(params[:id])
    else
      @environment = Environment.find_by_id(params[:id])
    end
    @servers = @environment.servers
  end

  def new
    @environment = Environment.new
    render :edit
  end

  def create
    @environment = Environment.new(params[:environment])
    if @environment.save
      flash[:notice] = "Environment \"#{@environment.name}\" has been created"
    else
      flash[:error] = "There was an error saving the environment. #{@environment.errors.full_messages}"
    end
    redirect_to root_url
  end
  
  def edit
    # TODO: Check ACL - SysAdmins only
    @environment = Environment.find(params[:id])
  end

  def update
    @environment = Environment.find(params[:id])
    if @environment.update_attributes(params[:environment])
      flash[:notice] = "The environment has been updated."
    else
      flash[:error] = "There was an error updating the environment. #{@environment.errors.full_messages}"
    end
  end

  def destroy
    # TODO: ACL check for admin
    environment = Environment.find(params[:id])
    if environment.destroy # make sure to have a well-paid lobbyist...
      flash[:notice] = "Environment \"#{environment.name}\" has been removed from the system."
    else
      flash[:error] = "Could not remove environment \"#{environment.name}\"."
      flash[:error] += "<br> Here is the error: #{environment.errors.to_s}" if environment.errors.present?
    end
    redirect_to root_url
  end




end
