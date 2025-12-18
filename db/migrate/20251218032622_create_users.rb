class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :name, null: false
      t.string :confirmation_token
      t.datetime :confirmation_sent_at
      t.datetime :confirmed_at
      t.string :remember_token
      t.datetime :remember_created_at
      t.string :password_reset_token
      t.datetime :password_reset_sent_at

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :confirmation_token, unique: true
    add_index :users, :remember_token, unique: true
    add_index :users, :password_reset_token, unique: true
  end
end
