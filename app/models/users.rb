class Users < ActiveRecord::Base
  attr_accessible :crypted_password, :first_name, :last_login_ip, :last_name, :oauth_token, :oauth_token_secret, :password_salt, :perishable_token, :persistence_token, :single_access_token, :username
end
