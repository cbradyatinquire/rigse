require 'fileutils'

class Admin::Project < ActiveRecord::Base
  set_table_name "admin_projects"
  
  belongs_to :user

  belongs_to :maven_jnlp_server, :class_name => "MavenJnlp::MavenJnlpServer"
  belongs_to :maven_jnlp_family, :class_name => "MavenJnlp::MavenJnlpFamily"
  
  has_many :project_vendor_interfaces, :class_name => "Admin::ProjectVendorInterface", :foreign_key => "admin_project_id"
  has_many :enabled_vendor_interfaces, :through => :project_vendor_interfaces, :class_name => "Probe::VendorInterface", :source => :probe_vendor_interface
  
  serialize :states_and_provinces
 
  acts_as_replicatable
  
  include Changeable
  include AppSettings
  
  self.extend SearchableModel
  
  @@searchable_attributes = %w{name description}

  validates_format_of :url, :with => URI::regexp(%w(http https))
  validates_length_of :name, :minimum => 1
  validate :states_and_provinces_array_members_must_match_list
  
  default_value_for :enabled_vendor_interfaces do
    Probe::VendorInterface.find(:all)
  end
  
  if USING_JNLPS
    validates_associated :maven_jnlp_server
    validates_associated :maven_jnlp_family
  end

  def states_and_provinces_array_members_must_match_list
    if states_and_provinces && states_and_provinces.is_a?(Array)
      unknown_provinces = states_and_provinces.select { |i| StatesAndProvinces::STATES_AND_PROVINCES[i] ? false : i }
      unless unknown_provinces.empty?
        errors.add(:states_and_provinces, "array members: #{unknown_provinces.join(', ')} must match list of known state and province two-character abreviations")
      end
    else
      errors.add(:states_and_provinces, "must be an array")
    end
  end

  def before_save
    if snapshot_enabled
      self.jnlp_version_str = maven_jnlp_family.snapshot_version
    end
  end
  
  def after_save
    if name == APP_CONFIG[:site_name] && url == APP_CONFIG[:site_url]
      update_app_settings
    end
    if self.enable_default_users
      User.unsuspend_default_users
    else
      User.suspend_default_users
    end
  end

  def update_app_settings
    new_app_settings = load_all_app_settings
    new_app_settings[RAILS_ENV][:site_name] = self.name
    new_app_settings[RAILS_ENV][:site_url] = self.url
    new_app_settings[RAILS_ENV][:enable_default_users] = self.enable_default_users
    new_app_settings[RAILS_ENV][:description] = self.description
    new_app_settings[RAILS_ENV][:states_and_provinces] = self.states_and_provinces
    new_app_settings[RAILS_ENV][:default_maven_jnlp] = generate_default_maven_jnlp
    save_app_settings(new_app_settings)
  end

  def generate_default_maven_jnlp
    if USING_JNLPS
      default_maven_jnlp =  APP_CONFIG[:default_maven_jnlp]
      default_maven_jnlp[:server] = self.maven_jnlp_server.name
      default_maven_jnlp[:family] = self.maven_jnlp_family.name
      if self.snapshot_enabled
        default_maven_jnlp[:version] = 'snapshot'
      else
        default_maven_jnlp[:version] = self.jnlp_version_str
      end
      default_maven_jnlp
    else
      nil
    end
  end
  
  
  def display_type
    self.default_project? ? 'Default ' : ''
  end
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
    
    # Admin::Project.default_project
    def default_project
      name, url = default_project_name_url
      proj = find_by_name_and_url(name, url)
      if ! proj
        logger.warn("No default project found for: #{name}, #{url}")
      end
      proj
    end
    
    def default_project_name_url
      [APP_CONFIG[:site_name], APP_CONFIG[:site_url]]
    end

    def display_name
      "Project"
    end
    
    def summary_info
      default_project ? default_project.summary_info : "no default project defined"
    end

    def create_or_update_default_project_from_settings_yml
      name, url = default_project_name_url
      states_and_provinces = APP_CONFIG[:states_and_provinces]

      if USING_JNLPS
        server, family, version = default_jnlp_info
        default_maven_jnlp =  APP_CONFIG[:default_maven_jnlp]
        maven_jnlp_server = MavenJnlp::MavenJnlpServer.find_by_name(server[:name])
        jnlp_family = maven_jnlp_server.maven_jnlp_families.find_by_name(family)
        jnlp_version_str = version
        if jnlp_version_str == 'snapshot'
          snapshot_enabled = true
          jnlp_family.update_snapshot_jnlp_url
          jnlp_url = jnlp_family.snapshot_jnlp_url
          jnlp_version_str = jnlp_url.version_str
        else
          snapshot_enabled = false
        end
      else
          maven_jnlp_server = nil
          jnlp_family = nil
          jnlp_version_str = nil
          snapshot_enabled = nil
      end
      
      enable_default_users = APP_CONFIG[:enable_default_users]

      attributes = {
        :name => name,
        :url => url,
        :user => User.site_admin,
        :enable_default_users => enable_default_users,
        :states_and_provinces => states_and_provinces,
        :maven_jnlp_server => maven_jnlp_server,
        :maven_jnlp_family => jnlp_family,
        :jnlp_version_str => jnlp_version_str,
        :snapshot_enabled => snapshot_enabled
      }
      unless project = Admin::Project.find_by_name_and_url(name, url)
        project = Admin::Project.create!(attributes)
      end
      project.user = User.site_admin
      project.enable_default_users = enable_default_users
      project.states_and_provinces = states_and_provinces
      project.maven_jnlp_server = maven_jnlp_server
      project.maven_jnlp_family = jnlp_family
      project.jnlp_version_str = jnlp_version_str
      project.snapshot_enabled = snapshot_enabled
      project.save!
      active_grades = APP_CONFIG[:active_grades]
      if ActiveRecord::Base.connection.table_exists?('portal_grades')
        active_grades.each do |grade_name|
          grade = Portal::Grade.find_or_create_by_name(:name => grade_name);
          unless grade
            grade = Portal::Grade.create(:name => grade_name, :active => true)
            puts "created grade #{grade.name}, active: #{grade.active}"
          end
        end
        Portal::Grade.find(:all).each do |grade|
          if (active_grades & [grade.name]).empty?
            grade.active = false
            puts "deactivated grade #{grade.name}, active: #{grade.active}"
          else
            grade.active = true
          end
          grade.save!
        end
      end
      project
    end

    # Returns an array of the default maven_jnlp server,  family, and jnlp snampshot version info
    # 
    # Example:
    # 
    #   server, family, version = Admin::Project.default_jnlp_info
    #
    #   server  # => {:path=>"/dev/org/concord/maven-jnlp/", :name=>"concord", :host=>"http://jnlp.concord.org"}
    #   family  # => "all-otrunk-snapshot"
    #   version # => "0.1.0-20091013.161730"
    #    
    def default_jnlp_info
      default_maven_jnlp = APP_CONFIG[:default_maven_jnlp]
      # => {:family=>"all-otrunk-snapshot", :version=>"snapshot", :server=>"concord"}
      server = APP_CONFIG[:maven_jnlp_servers].find { |s| s[:name] == default_maven_jnlp[:server] }
      # => {:path=>"/dev/org/concord/maven-jnlp/", :name=>"concord", :host=>"http://jnlp.concord.org"}
      family = default_maven_jnlp[:family]
      # => "all-otrunk-snapshot"
      version = default_maven_jnlp[:version]
      # => "snapshot"
      [server, family, version]
    end

  end
  
  def default_project?
    default_name, default_url = Admin::Project.default_project_name_url
    self.name == default_name && self.url == default_url
  end
  
  def summary_info
    puts <<HEREDOC

Portal::District: #{Portal::District.count}
Portal::School:   #{Portal::School.count}
Portal::Course:   #{Portal::Course.count}
Portal::Clazz:    #{Portal::Clazz.count}
Portal::Teacher:  #{Portal::Teacher.count}

Portal::Student:  #{Portal::Student.count}
Portal::Offering: #{Portal::Offering.count}
Portal::Learner:  #{Portal::Learner.count}

Dataservice::BundleLogger:  #{Dataservice::BundleLogger.count}
Dataservice::BundleContent: #{Dataservice::BundleContent.count}
Dataservice::ConsoleLogger:  #{Dataservice::ConsoleLogger.count}
Dataservice::ConsoleContent: #{Dataservice::ConsoleContent.count}

There are #{Portal::Clazz.find(:all).select {|i| i.teacher == nil}.size} Classes which no longer have Teachers
There are #{Portal::Learner.find(:all).select {|i| i.student == nil}.size} Learners which are no longer associated with Students

If these numbers are large you may want to consider cleaning up the database.

# code template for use in script/console

ut = User.find_by_login('teacher'); us = User.find_by_login('student')
t = ut.portal_teacher; s = us.portal_student; c = t.clazzes.first; o = c.offerings.first

HEREDOC
    
  end 
end
