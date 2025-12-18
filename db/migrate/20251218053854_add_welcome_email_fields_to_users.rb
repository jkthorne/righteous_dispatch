class AddWelcomeEmailFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :welcome_email_enabled, :boolean, default: false, null: false
    add_column :users, :welcome_email_subject, :string, default: "Welcome to our newsletter!"
    add_column :users, :welcome_email_content, :text, default: "Thank you for subscribing! We're excited to have you join our community."
  end
end
