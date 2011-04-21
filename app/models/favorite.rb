class Favorite < ActiveRecord::Base
  belongs_to :portal_teacher, :class_name => "Portal::Teacher", :foreign_key => "portal_teacher_id"
  belongs_to :favoritable, :polymorphic => true

  validates_uniqueness_of :favoritable_id, :scope => [:favoritable_type]
end
