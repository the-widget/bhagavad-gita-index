class Topic < ActiveRecord::Base
  has_many :users, through: :user_topics
  has_many :user_topics
  has_many :verses, through: :topic_verses
  has_many :topic_verses
  
  def slug
    self.name.split(" ").join("-")
  end

  def self.find_by_slug(input)
    self.all.find{ |find| find.slug == input}
  end

  def permissions(user)
    self.users << user
  end

end