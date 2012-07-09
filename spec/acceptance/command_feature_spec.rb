require 'spec_helper'
require 'acceptance/acceptance_helper'
require 'pp' # For developing/debugging spec


feature "Commands", %q{
  In order to run remote commands
  As an admin I want to run commands
  onto a remote server
} do

  background do
    # What the local user (running rake) will run tests as, as allowed in /etc/sudoers
    @invoking_user = "tupac"
    @ssh_private_key = "/home/tupac/.ssh/id_rsa"
    @ssh_public_key = "/home/tupac/.ssh/id_rsa.pub"
    # Fake "target server"
    @test_target_server = "localhost"
    @test_target_user = "tupac"
    @test_target_path = File.join(Rails.root, "/tmp/testing_fake_remote")
  end

  scenario "Command index" do
  #  page.should have_content('Available Servers')
  #  page.should have_content('Commands Available')
  end

  # Run a test
  # this will do the following:
  #   - Test existence of sudoers config for testing
  #   - If not in place, asks users to run it as root
  #   - Execute a request via the app
  #   - Test the result and output text
  #

  # Run a local test command
  scenario "Run a simulated remote command" do
    local_command = "echo '--- test #{@invoking_user} sudo ---'"
    command = "sudo -u #{@invoking_user} #{local_command}"
    stdin, stdout, stderr = Open3.popen3(command)
    $?.to_i.should eq(1). "Must be able to run command as #{@invoking_user} using sudo. Check sudoers config."
  end

  # Run an SSH test command
  scenario "Run a simulated remote command" do
    ssh_command = "ssh #{@test_target_user}@#{@test_target_server} echo '--- test #{@invoking_user} sudo ---'"
    command = "sudo -u #{@invoking_user} #{ssh_command}"
    stdin, stdout, stderr = Open3.popen3(command)
    $?.to_i.should eq(0)
    $?.to_i.should eq(1), "Must be able to run command as #{@invoking_user} using sudo with SSH to #{@TARGET_SERVER}. Check sudoers config AND check SSH keys."
  end

  #
  scenario "Run the echo test command against localhost" do
    pending "Impelement command model to run remote commands with"
  end
  
  # Edit a command
  
  # Delete a command

end
