# Configuration and checks for a "dummy" remote target server 
# environment, against which we can run tests
#
#RSpec.configure do |config|
#  # Note that this user doesn't have to be (and should not be) the same
#  # user that the web-server runs as. Generally it should be a "tupac" user
#  # which the webserver has sudo access to, for a limited set of commands.
#
#  # What the local user (running rake) will run tests as, as allowed in /etc/sudoers
#  config.invoking_user = "tupac"
#  ssh_private_key = "/home/tupac/.ssh/id_rsa"
#  ssh_public_key = "/home/tupac/.ssh/id_rsa.pub"
#  # Fake "target server"
#  test_target_server = "localhost"
#  test_target_user = "tupac"
#  test_target_path = File.join(Rails.root, "/tmp/testing_fake_remote")
#
#end
#@invoking_user = "tupac"
