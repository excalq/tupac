class WelcomeController < ApplicationController
  def index
    @commands = Command.order("created_at DESC")
  end
end
