require 'spec_helper'

include ApplicationHelper
describe RunnablesHelper do
  before :each do
    @anonymous_user = mock_model(User, :roles => ["guest"], :anonymous? => true, :name => "guest")
    @anonymous_user.stub!(:extra_params).and_return({})
    helper.stub!(:current_user).and_return(@anonymous_user)
    helper.stub!(:authenticate_with_http_basic).and_return nil
    @resource_page = mock_model(ResourcePage, :name => "Foo")
  end

  describe ".run_button_for" do
    it "should render a run button for a specified component" do
      helper.run_button_for(@resource_page).should == "<a href=\"http://test.host/resource_pages/#{@resource_page.id}.jnlp\" class=\"run_link rollover\" title=\"Run the Resource Page: 'Foo' as a Java Web Start application. The first time you do this it may take a while to startup as the Java code is downloaded and saved on your hard drive.\"><img alt=\"Run the Resource Page: 'Foo' as a Java Web Start application. The first time you do this it may take a while to startup as the Java code is downloaded and saved on your hard drive.\" src=\"/images/run.png?1295966927\" /></a>"
    end
  end

  describe ".preview_button_for" do
    it "should render a preview button for a specified component" do
      helper.preview_button_for(@resource_page).should == "<a href=\"http://test.host/resource_pages/#{@resource_page.id}.jnlp\" class=\"run_link rollover\" title=\"Preview the Resource Page: 'Foo' as a Java Web Start application. The first time you do this it may take a while to startup as the Java code is downloaded and saved on your hard drive.\"><img alt=\"Preview the Resource Page: 'Foo' as a Java Web Start application. The first time you do this it may take a while to startup as the Java code is downloaded and saved on your hard drive.\" src=\"/images/preview.png?1295966927\" /></a>"
    end
  end

  describe ".teacher_preview_button_for" do
    it "should render a preview button in techer mode for a given component" do
      helper.teacher_preview_button_for(@resource_page).should == "<a href=\"http://test.host/resource_pages/#{@resource_page.id}.jnlp?teacher_mode=true\" class=\"run_link rollover\" title=\"Preview the Resource Page: 'Foo' as a Teacher. The first time you do this it may take a while to startup as the Java code is downloaded and saved on your hard drive.\"><img alt=\"Preview the Resource Page: 'Foo' as a Teacher. The first time you do this it may take a while to startup as the Java code is downloaded and saved on your hard drive.\" src=\"/images/teacher_preview.png?1297111962\" /></a>"
    end
  end

  describe ".preview_link_for" do
    it "should render a preview link for a given component" do
      helper.preview_link_for(@resource_page).should == "<a href=\"http://test.host/resource_pages/#{@resource_page.id}.jnlp\" class=\"run_link rollover\" title=\"Preview the Resource Page: 'Foo' as a Java Web Start application. The first time you do this it may take a while to startup as the Java code is downloaded and saved on your hard drive.\"><img alt=\"Preview the Resource Page: 'Foo' as a Java Web Start application. The first time you do this it may take a while to startup as the Java code is downloaded and saved on your hard drive.\" src=\"/images/preview.png?1295966927\" /></a><a href=\"http://test.host/resource_pages/#{@resource_page.id}.jnlp\" title=\"Preview the Resource Page: 'Foo' as a Java Web Start application. The first time you do this it may take a while to startup as the Java code is downloaded and saved on your hard drive.\">preview </a>"
    end

    it "should render a preview link for a given component with parameters" do
      helper.preview_link_for(@resource_page, nil, {:link_text => "run Jeff's Leiderhosen"}).should == "<a href=\"http://test.host/resource_pages/#{@resource_page.id}.jnlp\" class=\"run_link rollover\" title=\"Preview the Resource Page: 'Foo' as a Java Web Start application. The first time you do this it may take a while to startup as the Java code is downloaded and saved on your hard drive.\"><img alt=\"Preview the Resource Page: 'Foo' as a Java Web Start application. The first time you do this it may take a while to startup as the Java code is downloaded and saved on your hard drive.\" src=\"/images/preview.png?1295966927\" /></a><a href=\"http://test.host/resource_pages/#{@resource_page.id}.jnlp\" title=\"Preview the Resource Page: 'Foo' as a Java Web Start application. The first time you do this it may take a while to startup as the Java code is downloaded and saved on your hard drive.\">run Jeff's Leiderhosen</a>"
    end
  end

  describe ".run_link_for" do
    it "should render a run link for a given component" do
      helper.run_link_for(@resource_page).should == "<a href=\"http://test.host/resource_pages/#{@resource_page.id}.jnlp\" class=\"run_link rollover\" title=\"Run the Resource Page: 'Foo' as a Java Web Start application. The first time you do this it may take a while to startup as the Java code is downloaded and saved on your hard drive.\"><img alt=\"Run the Resource Page: 'Foo' as a Java Web Start application. The first time you do this it may take a while to startup as the Java code is downloaded and saved on your hard drive.\" src=\"/images/run.png?1295966927\" /></a><a href=\"http://test.host/resource_pages/#{@resource_page.id}.jnlp\" title=\"Run the Resource Page: 'Foo' as a Java Web Start application. The first time you do this it may take a while to startup as the Java code is downloaded and saved on your hard drive.\">run </a>"
    end

    it "should render a run link for a given component with parameters" do
      helper.run_link_for(@resource_page, nil, {:link_text => "run Biscuits"}).should == "<a href=\"http://test.host/resource_pages/#{@resource_page.id}.jnlp\" class=\"run_link rollover\" title=\"Run the Resource Page: 'Foo' as a Java Web Start application. The first time you do this it may take a while to startup as the Java code is downloaded and saved on your hard drive.\"><img alt=\"Run the Resource Page: 'Foo' as a Java Web Start application. The first time you do this it may take a while to startup as the Java code is downloaded and saved on your hard drive.\" src=\"/images/run.png?1295966927\" /></a><a href=\"http://test.host/resource_pages/#{@resource_page.id}.jnlp\" title=\"Run the Resource Page: 'Foo' as a Java Web Start application. The first time you do this it may take a while to startup as the Java code is downloaded and saved on your hard drive.\">run Biscuits</a>"
    end

    it "should render a link for a resource page" do
      offering = mock_model(Portal::Offering, :name => "The Pajama Jammy Jam")
      offering.stub!(:runnable).and_return(mock_model(ResourcePage))
      offering.stub!(:resource_page?).and_return true
      helper.run_link_for(offering).should == "<a href=\"/resource_pages/#{offering.runnable.id}\" target=\"_blank\">View The Pajama Jammy Jam</a>"
    end

    it "should render a link for a JNLP type" do
      page = mock_model(Page, :name => "Fun With Hippos")
      helper.run_link_for(page).should == "<a href=\"http://test.host/pages/#{page.id}\" class=\"run_link rollover\" title=\"Run the Page: 'Fun With Hippos' as a Java Web Start application. The first time you do this it may take a while to startup as the Java code is downloaded and saved on your hard drive.\"><img alt=\"Run the Page: 'Fun With Hippos' as a Java Web Start application. The first time you do this it may take a while to startup as the Java code is downloaded and saved on your hard drive.\" src=\"/images/run.png?1295966927\" /></a><a href=\"http://test.host/pages/#{page.id}\" onclick=\"window.open(this.href);return false;\">run </a>"
    end
  end
end