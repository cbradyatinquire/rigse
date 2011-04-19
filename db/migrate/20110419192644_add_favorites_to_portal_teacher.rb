class AddFavoritesToPortalTeacher < ActiveRecord::Migration
  def self.up
    add_column :portal_teachers, :favorites_id, :integer
    add_column :portal_teachers, :favorites_type, :string
  end

  def self.down
    remove_column :portal_teachers, :favorites_type
    remove_column :portal_teachers, :favorites_id
  end
end
