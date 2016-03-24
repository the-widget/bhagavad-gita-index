class Topic < ActiveRecord::Base
  belongs_to :user
  has_many :verses, through: :topic_verses
  has_many :topic_verses
end