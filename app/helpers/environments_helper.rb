module EnvironmentsHelper

  # Takes an ActiveRecord server object
  def show_server_metadata(server)
    server.attributes.reject{|k,v| (["id", "status", "environment_id"].include?(k) or v.nil?)}.to_json
  end
end
