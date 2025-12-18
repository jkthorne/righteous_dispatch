class CreateNewsletters < ActiveRecord::Migration[8.1]
  def change
    create_table :newsletters do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.string :subject
      t.string :preview_text
      t.string :status, null: false, default: "draft"
      t.datetime :scheduled_at
      t.datetime :sent_at

      t.timestamps
    end

    add_index :newsletters, :status
    add_index :newsletters, [ :user_id, :status ]
    add_index :newsletters, :scheduled_at
  end
end
