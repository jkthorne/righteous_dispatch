class CreateSubscribers < ActiveRecord::Migration[8.1]
  def change
    create_table :subscribers do |t|
      t.references :user, null: false, foreign_key: true
      t.string :email, null: false
      t.string :first_name
      t.string :last_name
      t.string :status, null: false, default: "pending"
      t.datetime :subscribed_at
      t.datetime :unsubscribed_at
      t.datetime :confirmed_at
      t.string :confirmation_token

      t.timestamps
    end

    add_index :subscribers, [ :user_id, :email ], unique: true
    add_index :subscribers, :status
    add_index :subscribers, :confirmation_token, unique: true
  end
end
