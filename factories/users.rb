##
## Factories that have to do with setting up accounts.
##

##
## Emails and Logins will be derived from the login sequence
##

Factory.sequence(:login) do |n| 
  "login_#{UUIDTools::UUID.timestamp_create.to_s[0..20]}"
end

##
## Factory for user
##
Factory.define :user do |f|
  f.login    { Factory.next(:login) }
  f.first_name  'joe'
  f.last_name  'user' 
  f.email  { |u| "#{u.login}@concord.org"}
  f.password  'password' 
  f.password_confirmation  {|u| u.password}
  f.skip_notifications true
  f.roles  { [ Factory.next(:member_role)] }
  f.vendor_interface { |d| Probe::VendorInterface.find(:first) || Factory(:probe_vendor_interface) }
end


##
## Singleton Factory Pattern for Admin user.
##
Factory.sequence :admin_user do |n| 
  admin = User.find_by_login('admin') 
  unless admin
    admin = Factory(:user,
    {
      :login => 'admin',
      # :password =>'password',  # all passwords are 'password' (defined in user factory)
      :first_name => 'admin',
      :site_admin => 1,
      :roles => [Factory.next(:member_role),Factory.next(:admin_role)]
    })
    admin.register
    admin.activate
    admin.save!
  end
  admin
end

##
## Singleton Factory Pattern for Anonymous user.
##
Factory.sequence :anonymous_user do |n| 
  anon = User.find_by_login('anonymous') 
  unless anon
    anon = Factory(:user,
    {
      :login => 'anonymous',
      :first_name => 'anonymous',
      :roles => [Factory.next(:guest_role)]
    })
    anon.register
    anon.activate
    # clear any previous Anonymous user still cached as a class variable in the User class
    User.anonymous(true)
    anon.save!
  end
  anon
end

Factory.next(:anonymous_user)