class CreateTopicVerses < ActiveRecord::Migration
  def change
    create_table :topic_verses do |t|
      t.integer :topic_id
      t.integer :verse_id
    end
  end
end
