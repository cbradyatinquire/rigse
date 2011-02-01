class Portal::School < ActiveRecord::Base
  set_table_name :portal_schools
  has_settings
  
  acts_as_replicatable
  
  belongs_to :district, :class_name => "Portal::District", :foreign_key => "district_id"
  belongs_to :nces_school, :class_name => "Portal::Nces06School", :foreign_key => "nces_school_id"
  
  has_many :courses, :class_name => "Portal::Course", :foreign_key => "school_id"
  has_many :semesters, :class_name => "Portal::Semester", :foreign_key => "school_id"

  # has_many :grade_levels, :class_name => "Portal::GradeLevel", :foreign_key => "school_id"

  has_many :grade_levels, :as => :has_grade_levels, :class_name => "Portal::GradeLevel"
  has_many :grades, :through => :grade_levels, :class_name => "Portal::Grade"
  # has_many :clazzes, :through => :courses, :class_name => "Portal::Clazz"
  
  has_many :clazzes, :through => :courses, :class_name => "Portal::Clazz" do
    def active
      find(:all) & Portal::Clazz.has_offering
    end
  end

  has_many :school_memberships, :class_name => "Portal::SchoolMembership", :foreign_key => "school_id"

  # because of has_many polyporphs this means the the associations look like this:
  #
  #   school.portal_teachers
  #   school.portal_students
  #
  # but from the other side the 'portal' scoping isn't in the relationship
  #
  #   teacher.schools
  #   student.schools
  #
  
  # TODO: We should probably remove has_many_polymorphs all together.
  #  removed for students because it was interfering with manually written "schools" methods
  #has_many_polymorphs :members, :from => [:"portal/teachers", :"portal/students"], :through => :"portal/school_memberships"
  has_many_polymorphs :members, :from => [:"portal/teachers"], :through => :"portal/school_memberships"

  named_scope :real,    { :conditions => 'nces_school_id is NOT NULL' }  
  named_scope :virtual, { :conditions => 'nces_school_id is NULL' }  

  # TODO: Maybe this?  But also maybe nces_id.nil? technique instead??
  [:virtual?, :real?].each {|method| delegate method, :to=> :district }


  include Changeable

  self.extend SearchableModel
  
  @@searchable_attributes = %w{uuid name description}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
    
    def display_name
      "School"
    end
    
    ##
    ## Given an NCES local school id that matches the SEASCH field in an NCES school
    ## find and return the first district that is associated with the NCES or nil.
    ##
    ## example: 
    ##
    ##   Portal::School.find_by_state_and_nces_local_id('RI', 39123).name
    ##   => "Woonsocket High School"
    ##
    def find_by_state_and_nces_local_id(state, local_id)
      nces_school = Portal::Nces06School.find(:first, :conditions => {:SEASCH => local_id, :MSTATE => state}, 
        :select => "id, nces_district_id, NCESSCH, LEAID, SCHNO, STID, SEASCH, SCHNAM")
      if nces_school
        find(:first, :conditions=> {:nces_school_id => nces_school.id})
      end
    end

    ##
    ## Given a school name that matches the SEASCH field in an NCES school find
    ## and return the first school that is associated with the NCES school or nil.
    ##
    ## example: 
    ##
    ##   Portal::School.find_by_state_and_school_name('RI', "Woonsocket High School").nces_local_id
    ##   => "39123"
    ##
    def find_by_state_and_school_name(state, school_name)
      nces_school = Portal::Nces06School.find(:first, :conditions => {:SCHNAM => school_name.upcase, :MSTATE => state}, 
        :select => "id, nces_district_id, NCESSCH, LEAID, SCHNO, STID, SEASCH, SCHNAM")
      if nces_school
        find(:first, :conditions=> {:nces_school_id => nces_school.id})
      end
    end

    ##
    ## given a NCES school, find or create a portal school for it
    ##
    def find_or_create_by_nces_school(nces_school)
      found_instance = find(:first, :conditions=> {:nces_school_id => nces_school.id})
      unless found_instance
        attributes = {
          :name => nces_school.SCHNAM,
          :description => "imported from nces data",
          :nces_school_id => nces_school.id,
          :district => Portal::District.find_or_create_by_nces_district(nces_school.nces_district)
        }
        found_instance = create!(attributes)
      end
      found_instance
    end
    
  end

  ##
  ## Strange approach to alter the behavior of Clazz.children()
  ## to reflect a student-centric world view.
  ## ... (possibly a bad idea?)
  module FixupClazzes
    def parents
      return offerings
    end
  end
    
  ##
  ## required for the accordion view
  ##
  def children
    clazzes.map! {|c| c.extend(FixupClazzes)}
  end
  
  def children
    clazzes
  end
  
  ##
  ## sort of a hack
  ##
  def parent
    nil
  end
  
  def has_member?(student_or_teacher)
    members.detect {|m| m.class == student_or_teacher.class && m.id == student_or_teacher.id}
  end
  
  def add_member(student_or_teacher)
    return members if self.has_member?(student_or_teacher)
    members << student_or_teacher
  end
  
  # if the school is a 'real' school return the NCES local school id
  def nces_local_id
    real? ? nces_school.SEASCH : nil
  end
  
end
