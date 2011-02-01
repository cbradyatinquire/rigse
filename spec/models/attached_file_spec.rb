require 'spec_helper'

describe AttachedFile do
  
  describe "being created" do
    before do
      @attached_file = AttachedFile.new
    end
    
    it "should not be valid by default" do
      @attached_file.should_not be_valid
    end
    
    it "should require a user id, a name, and an 'attachable'" do
      %w( user_id name attachable_type attachable_id ).each do |attribute|      
        a = build_attached_file(attribute.to_sym => nil)
        a.should_not be_valid
        a.errors.on(attribute.to_sym).should_not be_nil
      end

      a = build_attached_file
      a.should be_valid
    end
    
    it "should upload a file" do
      a = build_attached_file({
        :attachment => File.new(RAILS_ROOT + '/spec/fixtures/images/rails.png')
      })
      a.should be_valid
      a.save
      
      a.attachment.should_not be_nil
      a.attachment_content_type.should == "image/png"
    end
  end
  
protected

  def build_attached_file(options = {})
    AttachedFile.new({
      :name => 'attachment', 
      :user_id => 1, 
      :attachable_type => 'Investigation', 
      :attachable_id => '1' }.merge(options))
  end
  
end