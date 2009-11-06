 #
# Setup
#
Given "a valid sakai user" do
  @sakai_login = "bowb_dobs"
  @rites_login = ExternalUserDomain.external_login_to_login(@sakai_login)
  @user = Factory(:user, {
    :login => @rites_login
  });
  @user.register
  @user.activate
  @user.login
end

Given "an unknown sakai user" do
  @user_login = "someunknownuser"
  while User.find_by_login(@user_login)
    @user_login << (rand * 100).to_i
  end
  @user = nil
end

#
# Actions
#
When "$actor goes to the link tool url" do |_|
  visit('/linktool', :get, {:serverurl => "http://moleman.concord.org/", :internaluser => @sakai_login})
end

#
# Result
#
Then "$actor should not be logged in" do |_|
  controller.logged_in?.should be_true
  controller.current_user.login.should == "anonymous"
end
  
Then "$actor should be logged in" do |_|
  controller.logged_in?.should be_true
  controller.current_user.login.should == @rites_login
end

Then "$actor should be forwarded to their home page" do |_|
  response.status.should == "200 OK"
  response.body.should include("Welcome to RITES Investigations")
  response.body.should match(/Welcome\n\s*#{@user.name}/)
end

Then "$actor should be shown a helpful error message" do |_|
  response.status.should == "200 OK"
  response.body.should include("Login failed")
end