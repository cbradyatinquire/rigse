namespace :rigse do
  
  PLUGIN_LIST = {
    :acts_as_taggable_on_steroids => 'http://svn.viney.net.nz/things/rails/plugins/acts_as_taggable_on_steroids',
    :attachment_fu => 'git://github.com/technoweenie/attachment_fu.git',
    :bundle_fu => 'git://github.com/timcharper/bundle-fu.git',
    :fudge_form => 'git://github.com/JimNeath/fudge_form.git',
    :haml => 'git://github.com/nex3/haml.git',
    :jrails => 'git://github.com/aaronchi/jrails.git',
    :open_id_authentication => 'git://github.com/rails/open_id_authentication.git',
    :paperclip => 'git://github.com/thoughtbot/paperclip.git',
    :salty_slugs => 'git://github.com/norbauer/salty_slugs.git',
    :shoulda => 'git://github.com/thoughtbot/shoulda.git',
    :spawn => 'git://github.com/tra/spawn.git',
    :workling => 'git://github.com/purzelrakete/workling.git'
  }
  
  desc 'List all plugins available to quick install'
  task :install do
    puts "\nAvailable Plugins\n=================\n\n"
    plugins = PLUGIN_LIST.keys.sort_by { |k| k.to_s }.map { |key| [key, PLUGIN_LIST[key]] }
    
    plugins.each do |plugin|
      puts "#{plugin.first.to_s.gsub('_', ' ').capitalize.ljust(30)} rake rigse:install:#{plugin.first.to_s}\n"
    end
    puts "\n"
  end
  
  namespace :install do
    PLUGIN_LIST.each_pair do |key, value|
      task key do
        system('script/plugin', 'install', value, '--force')
      end
    end
  end
  

  namespace :setup do
    
    desc "Raise an error unless the RAILS_ENV is development"
    task :development_environment_only do
      raise "Hey, development only you monkey!" unless RAILS_ENV == 'development'
    end

    desc "setup a new rigse instance"
    task :new_rigse_from_scratch => :environment do
      require 'highline/import'
      puts <<HEREDOC

This task will drop your extsing rigse database, rebuild it from scratch, 
and install default users.
  
HEREDOC
      if agree("Do you want to do this?  (y/n)", true)
        begin
          Rake::Task['db:drop'].invoke
        rescue Exception
        end
        Rake::Task['rigse:setup:development_environment_only'].invoke
        Rake::Task['db:create'].invoke
        Rake::Task['db:migrate'].invoke
        Rake::Task['rigse:setup:default_users_roles'].invoke
        Rake::Task['rigse:setup:create_additional_users'].invoke
  
        puts <<HEREDOC

You can now start RI-GSE in develelopment mode by running this command:

  script/server

You can re-edit the initial configuration parameters by running the
setup script again:

  ruby config/setup.rb

You can re-create the database from scratch and setup default users 
again by running this rake task again:

  rake rigse:setup:new_rigse_from_scratch
  
HEREDOC
      end
    end
    
    def edit_user(user)
      require 'highline/import'
      
      puts <<HEREDOC

Editing user: #{user.login}

HEREDOC

      user.login =                 ask("            login: ") {|q| q.default = user.login}
      user.email =                 ask("            email: ") {|q| q.default = user.email}
      user.first_name =            ask("       first name: ") {|q| q.default = user.first_name}
      user.last_name =             ask("        last name: ") {|q| q.default = user.last_name}
      user.password =              ask("         password: ") {|q| q.default = user.password}
      user.password_confirmation = ask(" confirm password: ") {|q| q.default = user.password_confirmation}
      
      user
    end

    #
    # additional_users.yml is a YAML file that includes a list of users
    # to create when setting up a new instance. The salt and crypted_password
    # are specified for these users.
    #
    # A role specification is optional.
    #
    # Here's an example of how to create and additional_users.yml file:
    #
    # additional_users = { "stephen" =>
    #   { "salt"=>"6a0172c1678bf48badba84cdc0ba6be3071583ae", 
    #     "crypted_password"=>"7e11934911cee011e26eaece4b4ca5de58141728", 
    #     "role"=>"admin", 
    #     "first_name"=>"Stephen", 
    #     "last_name"=>"Bannasch", 
    #     "email"=>"stephen.bannasch@gmail.com"}
    #   }
    # File.open(File.join(RAILS_ROOT, %w{config additional_users.yml}), 'w') {|f| YAML.dump(contacts, f)}
    # 
    # One way to create salt and crypted_password values for a user is to
    # perform the following operations in script/console with any valid user object:
    #
    #   salt = User.make_token
    #   crypted_password = user.encrypt('passwd')
    #
    # The salt is based on the REST_AUTH_SITE_KEY which is normally different
    # for development and production deployment environments. The values for salt
    # and crypted_password should be calculated using the REST_AUTH_SITE_KEY in
    # the desired deployment environment.
    #
    desc "Create additional users from additional_users.yml file."
    task :create_additional_users => :environment do
      begin
        path = File.join(RAILS_ROOT, %w{config additional_users.yml})
        additional_users = YAML::load(IO.read(path))
        puts "\nCreating additional users ...\n\n"
        additional_users.each do |user_config|
          puts "  #{user_config[1]['role']} #{user_config[0]}: #{user_config[1]['first_name']} #{user_config[1]['last_name']}, #{user_config[1]['email']}"
          u = User.create(:login => user_config[0], 
            :first_name => user_config[1]['first_name'], 
            :last_name => user_config[1]['last_name'], 
            :email => user_config[1]['email'], 
            :password => "password", 
            :password_confirmation => "password")
          u = User.find_by_login(user_config[0])
          u.update_attribute('crypted_password', user_config[1]['crypted_password'])
          u.update_attribute('salt', user_config[1]['salt'])
          u.register!
          u.activate!
          role_title = user_config[1]['role']
          if role_title
            role = Role.find_by_title(role_title)
            u.roles << role
          end
        end
        puts "\n\n"
      rescue SystemCallError => e
        # puts e.class
        # puts "#{path} not found"
      end
    end
    
    desc "Create default users and roles"
    task :default_users_roles => :environment do

      puts <<HEREDOC

This task creates four roles (if they don't already exist):

  admin
  researcher
  member
  guest

In addition it create three new default users with these logins:

  admin
  researcher
  member

You can edit the default settings for these users.

HEREDOC

      admin_role = Role.find_or_create_by_title('admin')
      researcher_role = Role.find_or_create_by_title('researcher')
      member_role = Role.find_or_create_by_title('member')
      guest_role = Role.find_or_create_by_title('guest')

      admin_user = User.create(:login => "admin", :email => "admin@concord.org", :password => "password", :password_confirmation => "password", :first_name => "Admin", :last_name => "User")
      researcher_user = User.create(:login => 'researcher', :first_name => 'Researcher', :last_name => 'User', :email => 'researcher@concord.org', :password => "password", :password_confirmation => "password")
      member_user = User.create(:login => 'member', :first_name => 'Member', :last_name => 'User', :email => 'member@concord.org', :password => "password", :password_confirmation => "password")

      [admin_user, researcher_user, member_user].each do |user|
        user = edit_user(user)
        user.save
        user.register!
        user.activate!
      end

      admin_user.roles << admin_role 
      researcher_user.roles << researcher_role
      
    end
  end
end