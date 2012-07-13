require 'spec_helper'

describe WelcomeController do

  before :each do
    get :index
  end

  describe "GET /" do
    render_views

    describe "as an admin user" do
      it "should allow login" do
        response.should be_success
        page.has_selector?(:app_description, :text => 'Welcome to Tupac')
      end

      it "should show create action links" do
        page.has_selector?(:main_action_links, :text => 'Create New Environment')
        page.has_selector?(:main_action_links, :text => 'Create New Command')
      end

      it "should show lists of environments and commands" do 
        page.has_selector?(:contents, :text => 'Environments')
      end
    end

    describe "as a deployer user" do
      it "should allow login" do
        response.should be_success
        page.has_selector?(:app_description, :text => 'Welcome to Tupac')
      end

      it "should NOT show create action links" do
        pending "Add user authentication!"
        response.body.should_not have_text("Create New Environment")
        response.body.should_not have_text("Create New Command")
      end

      it "should show lists of environments and commands" do 
        pending "Add environments and commands factory"
      end
    end

    describe "as an unprivileged user" do
      it "should reject the user" do
        pending "Add user authentication!"
        response.should redirect_to(login_url)
      end
    end

  end
end
