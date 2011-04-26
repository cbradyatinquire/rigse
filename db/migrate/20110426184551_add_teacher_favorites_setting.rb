class AddTeacherFavoritesSetting < ActiveRecord::Migration
  def self.up
    add_column :admin_projects, :enable_teacher_favorites, :boolean, :default => false
  end

  def self.down
    remove_column :admin_projects, :enable_teacher_favorites
  end
end
