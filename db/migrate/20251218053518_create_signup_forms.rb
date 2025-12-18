class CreateSignupForms < ActiveRecord::Migration[8.1]
  def change
    create_table :signup_forms do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.string :headline, default: "Subscribe to our newsletter"
      t.text :description
      t.string :button_text, default: "Subscribe"
      t.text :success_message, default: "Thanks for subscribing!"
      t.boolean :active, default: true, null: false
      t.string :public_id, null: false

      t.timestamps
    end

    add_index :signup_forms, :public_id, unique: true

    # Join table for auto-tagging new subscribers
    create_table :signup_form_tags do |t|
      t.references :signup_form, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true
      t.timestamps
    end

    add_index :signup_form_tags, [:signup_form_id, :tag_id], unique: true
  end
end
