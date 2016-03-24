class Verse < ActiveRecord::Base
  has_many :topics, through: :topic_verses
  has_many :topic_verses
end