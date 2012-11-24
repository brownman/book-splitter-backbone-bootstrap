class AddUrlSoundToComments < ActiveRecord::Migration
  def change
    add_column :comments, :url_sound, :string
  end
end
