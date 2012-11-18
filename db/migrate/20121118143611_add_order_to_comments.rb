class AddOrderToComments < ActiveRecord::Migration
  def change
    add_column :comments, :order, :integer
  end
end
