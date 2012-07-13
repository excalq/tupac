require 'spec_helper'

describe EnvironmentsController do

  # TODO: User authentication
  # TODO: Factory create environment
  def create_environment
    @environment = FactoryGirl.create :environment, :name => 'test_environment', :description => 'An example environment'
  end


    describe "GET index" do
    it "assigns @environments" do
      environment = Environment.create
      get :index
      assigns(:environments).should eq([environment])
    end

    it "renders the index template" do
      get :index
      response.should render_template("index")
    end
  end

  describe "POST create" do
    # post hash of new environment data
    it "creates a new environment" do
      post :create

      # check record +1
      # check flash message
    end
  end

  # UPDATE
  describe "PUT environments/:name" do
    before :each do create_environment end

    it "updates the environment record" do
      put :update, :id => "1", :name => "Environment of Radness!"
      # check record
      Environment.where(:name => 'Environment of Radness!').count.should eq(1)
      # check flash message
      flash[:notice].should_not be_blank
    end
  end

  describe "DELETE environment" do
    before :each do create_environment end

    it "should delete the environment" do
      expect{
        delete :destroy, id: @environment
      }.to change(Environment, :count).by(-1)
    end

    it "redirects to the homepage" do
      delete :destroy, id: @environment
      response.should redirect_to root_url
      flash[:notice].should_not be_blank
    end
  end

end
