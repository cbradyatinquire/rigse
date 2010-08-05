require 'spec_helper'
#include ApplicationHelper

describe InvestigationsController do
  integrate_views

  before(:each) do
    generate_default_project_and_jnlps_with_mocks
    Admin::Project.stub!(:default_project).and_return(@mock_project)
    
    @admin_user = Factory.create(:user, { :email => "test@test.com", :password => "password", :password_confirmation => "password" })
    @admin_user.add_role("admin")
    
    stub_current_user :admin_user
    
    @investigation = Factory.create(:investigation, {
      :name => "test investigation",
      :description => "new decription"
    })
    Investigation.stub!(:find).and_return(@investigation)
  end

  it "should display a 'duplicate' link for authorized users" do
    @investigation.should_receive(:duplicateable?).with(@logged_in_user).and_return(true)

    get :show, :id => @investigation.id
    
    #@response.body.should include(duplicate_link_for(@investigation))
    assert_select("a[href=?]", duplicate_investigation_url(@investigation), { :text => "duplicate", :count => 1 })
  end
  
  it "should not display a 'duplicate' link for unauthorized users" do
    @investigation.should_receive(:duplicateable?).with(@logged_in_user).and_return(false)

    get :show, :id => @investigation.id
    
    #@response.body.should_not include(duplicate_link_for(@investigation))
    assert_select("a[href=?]", duplicate_investigation_url(@investigation), { :text => "duplicate", :count => 0 })
  end

  
  it "should render prievew warning in OTML" do
    get :show, :id => @investigation.id, :format => 'otml'
    assert_select "*.warning", preview_warning_message # defined in otml_helper.rb
  end

  it "should render overlay removing warning in dynamic_otml" do
    get :show, :id => @investigation.id, :format => 'dynamic_otml'
    assert_select "overlays" do
      assert_select "OTOverlay" do
        assert_select "deltaObjectMap" do
          assert_select "entry[key=?]", "#{@investigation.uuid}!/preview_warning"
        end
      end
    end
  end

end
