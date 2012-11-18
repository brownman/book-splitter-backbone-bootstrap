class AddDirectionToComments < ActiveRecord::Migration
  def change
    add_column :comments, :direction, :boolean

  end
end
