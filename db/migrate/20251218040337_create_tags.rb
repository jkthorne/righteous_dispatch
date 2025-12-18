class CreateTags < ActiveRecord::Migration[8.1]
  def change
    create_table :tags do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :color, default: "#3b82f6"

      t.timestamps
    end

    add_index :tags, [ :user_id, :name ], unique: true

    # Join table for subscribers and tags
    create_table :subscriber_tags do |t|
      t.references :subscriber, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end

    add_index :subscriber_tags, [ :subscriber_id, :tag_id ], unique: true
  end
end
