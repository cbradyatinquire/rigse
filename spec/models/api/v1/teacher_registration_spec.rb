# encoding: utf-8
require 'spec_helper'

describe API::V1::TeacherRegistration do
  let(:params) {
     { 
        first_name: "teacher",
        last_name: "doe",
        login: "teacher_user",
        password: "testingxxy",
        email: "teacher@concord.org",
        school_id: 123
    }
  }
  
  it_behaves_like 'user registration' do
    before(:each) do
      Portal::School.stub!(:find).and_return(mock_model(Portal::School))
    end
    let(:good_params) { params }
  end

  describe "school_id validations" do
    subject { API::V1::TeacherRegistration.new(params) }
    
    describe "no school found" do
      before(:each) do
        Portal::School.stub!(:find).and_return(nil)
      end
      it { 
        should_not be_valid
        should have(1).error_on :"school_id" 
      }
    end

    describe "school found" do
      before(:each) do
        Portal::School.stub!(:find).and_return(mock_model(Portal::School))
      end
      it {  should be_valid }
    end
  end
 end
 