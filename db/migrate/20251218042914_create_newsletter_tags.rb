class CreateNewsletterTags < ActiveRecord::Migration[8.1]
  def change
    create_table :newsletter_tags do |t|
      t.references :newsletter, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end

    add_index :newsletter_tags, [ :newsletter_id, :tag_id ], unique: true
  end
end
