class Comment < ActiveRecord::Base
  belongs_to :post

  validates :title, :presence => true

  validates :content, :presence => true

  validates :order, :numericality => { :only_integer => true }
end
