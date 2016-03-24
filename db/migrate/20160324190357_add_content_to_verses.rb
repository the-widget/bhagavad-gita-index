class AddContentToVerses < ActiveRecord::Migration
  def change
    change_table :verses do |t|
      t.string :content 
    end
  end
end

