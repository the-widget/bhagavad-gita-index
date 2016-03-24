class User < ActiveRecord::Base
  has_many :topics, through: :user_topics
  has_many :user_topics
  has_secure_password
end