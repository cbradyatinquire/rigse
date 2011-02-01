Given /^the following students exist:$/ do |table|
  User.anonymous(true)
  table.hashes.each do |hash|
    begin
      user = Factory(:user, hash)
      user.add_role("member")
      user.register
      user.activate
      user.save!
      
      portal_student = Factory(:full_portal_student, { :user => user })
      portal_student.save!
    rescue ActiveRecord::RecordInvalid
      # assume this user is already created...
    end
  end
end


Given /^the student "(.*)" belongs to class "(.*)"$/ do |student_name, class_name| 
  student = User.find_by_login(student_name).portal_student
  clazz   = Portal::Clazz.find_by_name(class_name)
  
  Factory.create :portal_student_clazz, :student => student,
                                        :clazz   => clazz
end
