class CreateEmailEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :email_events do |t|
      t.references :newsletter, null: false, foreign_key: true
      t.references :subscriber, null: false, foreign_key: true
      t.string :event_type, null: false
      t.jsonb :metadata, default: {}
      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end

    add_index :email_events, :event_type
    add_index :email_events, [:newsletter_id, :event_type]
    add_index :email_events, [:newsletter_id, :subscriber_id, :event_type], name: "idx_email_events_unique_open", unique: true, where: "event_type = 'open'"
  end
end
