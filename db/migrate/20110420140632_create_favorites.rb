class CreateFavorites < ActiveRecord::Migration
  def self.up
    create_table :favorites do |t|
      t.references :portal_teacher
      t.references :favoritable, :polymorphic => true
      t.timestamps
    end
  end

  def self.down
    drop_table :favorites
  end
end
