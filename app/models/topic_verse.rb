class TopicVerse < ActiveRecord::Base
  belongs_to :verse
  belongs_to :topic 

end