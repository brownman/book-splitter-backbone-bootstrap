class AddUrlSoundToComments < ActiveRecord::Migration
  def change
    add_column :comments, :url_sounds, :string
  end
end
