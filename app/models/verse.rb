class Verse < ActiveRecord::Base
  has_many :topics, through: :topic_verses
  has_many :topic_verses

  def chapter_name
    num = self.chapter.to_s.to_i
    case num
    when 1
      "Observing the Armies on the Battleﬁeld of Kurukṣetra"
    when 2
      "Contents of the Gītā Summarized"
    when 3
      "Karma-yoga"
    when 4
      "Transcendental Knowledge"
    when 5
      "Karma-yoga – Action in Kṛṣṇa Consciousness"
    when 6
      "Dhyāna-yoga"
    when 7
      "Knowledge of the Absolute"
    when 8
      "Attaining the Supreme"
    when 9
      "The Most Conﬁdential Knowledge"
    when 10
      "The Opulence of the Absolute"
    when 11
      "The Universal Form"
    when 12
      "Devotional Service"
    when 13
      "Nature, the Enjoyer and Consciousness"
    when 14
      "The Three Modes of Material Nature"
    when 15
      "The Yoga of the Supreme Person"
    when 16
      "The Divine and Demoniac Natures"
    when 17
      "The Divisions of Faith"
    when 18
      "Conclusion – The Perfection of Renunciation"
    end
  end

  def chapter
    self.location.match(/^\d+/).to_s.to_i
  end

  def verse
    self.location.match(/[^\.]\d?$/).to_s.to_i
  end
end