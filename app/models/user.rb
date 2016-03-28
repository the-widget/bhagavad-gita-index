class User < ActiveRecord::Base
  has_many :topics, through: :user_topics
  has_many :user_topics
  has_secure_password

  def verses
    topics = Topic.all
    verses = []
    self.topics.each do |t|
      verses << t.verses
    end
    verses.sort!{|a,b| a.location <=> b.location}
  end
end