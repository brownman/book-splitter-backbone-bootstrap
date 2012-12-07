class AddKeyframesToComments < ActiveRecord::Migration
  def change
    add_column :comments, :keyframes, :text
  end
end
