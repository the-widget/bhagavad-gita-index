class Topic < ActiveRecord::Base
  belongs_to :user
  has_many :verses, through: :topic_verses
  has_many :topic_verses

  def slug
    self.name.split(" ").join("-")
  end

  def self.find_by_slug(input)
    self.all.find{ |find| find.slug == input}
  end
  
end