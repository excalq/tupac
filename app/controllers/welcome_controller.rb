class WelcomeController < ApplicationController
  def index
    @environments = Environment.order("created_at DESC")
    @commands = Command.order("created_at DESC")
  end
end
