# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Seeding database..."

# Create demo user with welcome email settings
user = User.find_or_initialize_by(email: "demo@righteousdispatch.com")
user.assign_attributes(
  name: "Demo User",
  password: "password123",
  password_confirmation: "password123",
  confirmed_at: Time.current,
  welcome_email_enabled: true,
  welcome_email_subject: "Welcome to RighteousDispatch!",
  welcome_email_content: "Thank you for subscribing to our newsletter!\n\nWe're excited to have you join our faith community. You'll receive regular updates including devotionals, community news, and prayer requests.\n\nMay God bless you abundantly!\n\n— The RighteousDispatch Team"
)
user.save!
puts "Created user: #{user.email} (password: password123)"

# Create tags
tag_names = ["VIP", "New Subscriber", "Monthly Donor", "Prayer Warrior", "Volunteer", "Pastor"]
tags = tag_names.map do |name|
  Tag.find_or_create_by!(user: user, name: name)
end
puts "Created #{tags.count} tags"

# Create subscribers
subscribers_data = [
  { email: "john.smith@example.com", first_name: "John", last_name: "Smith", status: :confirmed },
  { email: "mary.johnson@example.com", first_name: "Mary", last_name: "Johnson", status: :confirmed },
  { email: "david.williams@example.com", first_name: "David", last_name: "Williams", status: :confirmed },
  { email: "sarah.brown@example.com", first_name: "Sarah", last_name: "Brown", status: :confirmed },
  { email: "michael.jones@example.com", first_name: "Michael", last_name: "Jones", status: :confirmed },
  { email: "jennifer.davis@example.com", first_name: "Jennifer", last_name: "Davis", status: :pending },
  { email: "robert.miller@example.com", first_name: "Robert", last_name: "Miller", status: :pending },
  { email: "lisa.wilson@example.com", first_name: "Lisa", last_name: "Wilson", status: :unsubscribed },
  { email: "james.moore@example.com", first_name: "James", last_name: "Moore", status: :bounced },
  { email: "patricia.taylor@example.com", first_name: "Patricia", last_name: "Taylor", status: :confirmed },
  { email: "william.anderson@example.com", first_name: "William", last_name: "Anderson", status: :confirmed },
  { email: "elizabeth.thomas@example.com", first_name: "Elizabeth", last_name: "Thomas", status: :confirmed },
]

subscribers = subscribers_data.map do |data|
  subscriber = Subscriber.find_or_initialize_by(user: user, email: data[:email])
  subscriber.assign_attributes(data)
  subscriber.save!
  subscriber
end
puts "Created #{subscribers.count} subscribers"

# Assign tags to some subscribers
vip_tag = tags.find { |t| t.name == "VIP" }
new_sub_tag = tags.find { |t| t.name == "New Subscriber" }
donor_tag = tags.find { |t| t.name == "Monthly Donor" }
prayer_tag = tags.find { |t| t.name == "Prayer Warrior" }
volunteer_tag = tags.find { |t| t.name == "Volunteer" }
pastor_tag = tags.find { |t| t.name == "Pastor" }

# John Smith - VIP, Monthly Donor
subscribers[0].tags = [vip_tag, donor_tag]
# Mary Johnson - Prayer Warrior
subscribers[1].tags = [prayer_tag]
# David Williams - Pastor, VIP
subscribers[2].tags = [pastor_tag, vip_tag]
# Sarah Brown - Volunteer, Prayer Warrior
subscribers[3].tags = [volunteer_tag, prayer_tag]
# Michael Jones - New Subscriber
subscribers[4].tags = [new_sub_tag]
# Patricia Taylor - Monthly Donor
subscribers[9].tags = [donor_tag]
# William Anderson - Volunteer
subscribers[10].tags = [volunteer_tag]

puts "Assigned tags to subscribers"

# Create newsletters
newsletters_data = [
  {
    title: "Welcome to RighteousDispatch",
    subject: "Welcome to Our Faith Community Newsletter",
    content: <<~HTML,
      <h2>Welcome, Fellow Believers!</h2>
      <p>We're thrilled to have you join our faith community. RighteousDispatch is more than just a newsletter—it's a way to stay connected with what God is doing in our midst.</p>
      <h3>What to Expect</h3>
      <ul>
        <li>Weekly devotionals and scripture reflections</li>
        <li>Community updates and prayer requests</li>
        <li>Upcoming events and volunteer opportunities</li>
        <li>Testimonies of God's faithfulness</li>
      </ul>
      <p>We encourage you to reply to our emails with your prayer requests. We have a team of dedicated prayer warriors who lift up every request.</p>
      <p><strong>May God bless you abundantly!</strong></p>
    HTML
    status: :sent,
    sent_at: 2.weeks.ago,
    tag_names: [] # Sent to all subscribers
  },
  {
    title: "Weekly Devotional: Walking in Faith",
    subject: "This Week's Devotional: Walking in Faith",
    content: <<~HTML,
      <h2>Walking in Faith</h2>
      <blockquote>"For we walk by faith, not by sight." — 2 Corinthians 5:7</blockquote>
      <p>In a world that demands evidence and proof, faith calls us to trust in what we cannot see. This week, we're reflecting on what it means to truly walk by faith.</p>
      <h3>Three Steps of Faith</h3>
      <ol>
        <li><strong>Trust God's Timing</strong> — His plans are perfect, even when we don't understand them.</li>
        <li><strong>Obey His Word</strong> — Faith without works is dead. Let your actions reflect your belief.</li>
        <li><strong>Rest in His Promises</strong> — He who promised is faithful.</li>
      </ol>
      <p>This week, choose one area of your life where you've been relying on sight instead of faith. Surrender it to God and watch Him work.</p>
    HTML
    status: :sent,
    sent_at: 1.week.ago,
    tag_names: [] # Sent to all subscribers
  },
  {
    title: "Community Update: Summer Events",
    subject: "Exciting Summer Events Coming Up!",
    content: <<~HTML,
      <h2>Summer Is Here!</h2>
      <p>We have an exciting lineup of events planned for this summer. Mark your calendars!</p>
      <h3>Upcoming Events</h3>
      <ul>
        <li><strong>Vacation Bible School</strong> — July 15-19, 9 AM - 12 PM</li>
        <li><strong>Community Picnic</strong> — July 27, 12 PM at City Park</li>
        <li><strong>Youth Camp</strong> — August 5-9</li>
        <li><strong>Back-to-School Blessing</strong> — August 18</li>
      </ul>
      <p>Volunteers are needed for all events! Reply to this email if you'd like to serve.</p>
    HTML
    status: :sent,
    sent_at: 3.days.ago,
    tag_names: ["Volunteer"] # Sent only to volunteers
  },
  {
    title: "Prayer Request Update",
    subject: "Answered Prayers & New Requests",
    content: <<~HTML,
      <h2>God Answers Prayer!</h2>
      <p>We serve a faithful God who hears and answers our prayers. Here are some praise reports from our community:</p>
      <h3>Praise Reports</h3>
      <ul>
        <li>The Johnson family welcomed a healthy baby girl!</li>
        <li>Brother Mike's surgery was successful—he's recovering well.</li>
        <li>Sister Patricia found employment after 6 months of searching.</li>
      </ul>
      <h3>Continued Prayer Needs</h3>
      <ul>
        <li>The Williams family as they grieve the loss of their father.</li>
        <li>Our missionaries in Southeast Asia.</li>
        <li>Revival in our community.</li>
      </ul>
    HTML
    status: :scheduled,
    scheduled_at: 2.days.from_now.beginning_of_hour,
    tag_names: ["Prayer Warrior"] # Targeted to prayer warriors
  },
  {
    title: "Monthly Donor Appreciation",
    subject: "Thank You, Faithful Givers!",
    content: <<~HTML,
      <h2>You Make a Difference</h2>
      <p>To our monthly donors: THANK YOU. Your faithful giving enables us to continue the work God has called us to.</p>
      <p>This month, your generosity has helped:</p>
      <ul>
        <li>Feed 150 families through our food pantry</li>
        <li>Support 3 families with emergency rent assistance</li>
        <li>Provide school supplies for 75 children</li>
      </ul>
      <p>You are storing up treasures in heaven. God sees your faithfulness.</p>
    HTML
    status: :draft,
    tag_names: ["Monthly Donor", "VIP"] # Targeted to donors and VIPs
  },
  {
    title: "Pastor's Corner: Leadership Insights",
    subject: "Monthly Leadership Message",
    content: <<~HTML,
      <h2>Dear Fellow Shepherds,</h2>
      <p>As pastors and ministry leaders, we carry a unique responsibility. This month, I want to share some thoughts on servant leadership.</p>
      <h3>Key Principles</h3>
      <ol>
        <li><strong>Lead by Example</strong> — Our actions speak louder than our sermons.</li>
        <li><strong>Invest in Others</strong> — The measure of our leadership is the leaders we develop.</li>
        <li><strong>Stay Humble</strong> — We are under-shepherds serving the Chief Shepherd.</li>
      </ol>
      <p>Let's continue to support and pray for one another in this sacred calling.</p>
      <p>Grace and peace,<br>Pastor Demo</p>
    HTML
    status: :draft,
    tag_names: ["Pastor"] # Targeted only to pastors
  },
  {
    title: "New Member Welcome Series",
    subject: "Getting Started with Our Community",
    content: <<~HTML,
      <h2>Welcome to the Family!</h2>
      <p>We're so glad you've joined us. Here's everything you need to know to get connected:</p>
      <h3>Next Steps</h3>
      <ul>
        <li><strong>Connect Card</strong> — Fill out your profile so we can get to know you better.</li>
        <li><strong>Join a Group</strong> — Small groups meet weekly for fellowship and Bible study.</li>
        <li><strong>Serve</strong> — Discover your gifts and find a place to serve.</li>
        <li><strong>Give</strong> — Partner with us in advancing God's kingdom.</li>
      </ul>
      <p>Have questions? Simply reply to this email—we'd love to hear from you!</p>
    HTML
    status: :scheduled,
    scheduled_at: 1.week.from_now.beginning_of_hour,
    tag_names: ["New Subscriber"] # Targeted to new subscribers
  }
]

newsletters_data.each do |data|
  newsletter = Newsletter.find_or_initialize_by(user: user, title: data[:title])
  newsletter.assign_attributes(
    subject: data[:subject],
    status: data[:status],
    scheduled_at: data[:scheduled_at],
    sent_at: data[:sent_at]
  )
  newsletter.content = data[:content]
  newsletter.save!

  # Assign tags to newsletter for targeted sending
  if data[:tag_names].present?
    newsletter_tags = tags.select { |t| data[:tag_names].include?(t.name) }
    newsletter.tags = newsletter_tags
  else
    newsletter.tags = []
  end
end
puts "Created #{newsletters_data.count} newsletters"

# Create signup forms
signup_forms_data = [
  {
    title: "Homepage Signup",
    headline: "Stay Connected with Our Community",
    description: "Get weekly devotionals, prayer updates, and community news delivered to your inbox.",
    button_text: "SUBSCRIBE",
    success_message: "Welcome to our community! Check your inbox for a welcome message.",
    active: true,
    tag_names: ["New Subscriber"]
  },
  {
    title: "Blog Sidebar Form",
    headline: "Subscribe to Our Newsletter",
    description: "Never miss an update. Join thousands of believers.",
    button_text: "JOIN NOW",
    success_message: "Thanks for subscribing! You'll hear from us soon.",
    active: true,
    tag_names: []
  },
  {
    title: "Prayer Warrior Signup",
    headline: "Join Our Prayer Team",
    description: "Receive weekly prayer requests and updates. Be part of our prayer warrior network.",
    button_text: "JOIN PRAYER TEAM",
    success_message: "Welcome to the prayer team! You'll receive prayer requests weekly.",
    active: true,
    tag_names: ["Prayer Warrior"]
  },
  {
    title: "VIP List (Inactive)",
    headline: "Join the VIP List",
    description: "Exclusive content for our most engaged subscribers.",
    button_text: "BECOME A VIP",
    success_message: "Welcome to the VIP list!",
    active: false,
    tag_names: ["VIP"]
  }
]

signup_forms = signup_forms_data.map do |data|
  form = SignupForm.find_or_initialize_by(user: user, title: data[:title])
  form.assign_attributes(
    headline: data[:headline],
    description: data[:description],
    button_text: data[:button_text],
    success_message: data[:success_message],
    active: data[:active]
  )
  form.save!

  # Assign tags
  if data[:tag_names].present?
    form_tags = tags.select { |t| data[:tag_names].include?(t.name) }
    form.tags = form_tags
  else
    form.tags = []
  end

  form
end
puts "Created #{signup_forms.count} signup forms"

# Create email events for sent newsletters (analytics demo data)
sent_newsletters = Newsletter.where(user: user, status: :sent)
confirmed_subscribers = Subscriber.where(user: user, status: :confirmed)

sent_newsletters.each do |newsletter|
  # Simulate opens for 60-80% of subscribers
  open_rate = rand(60..80) / 100.0
  openers = confirmed_subscribers.sample((confirmed_subscribers.count * open_rate).to_i)

  openers.each do |subscriber|
    EmailEvent.find_or_create_by(
      newsletter: newsletter,
      subscriber: subscriber,
      event_type: EmailEvent::OPEN
    ) do |event|
      event.ip_address = "#{rand(1..255)}.#{rand(1..255)}.#{rand(1..255)}.#{rand(1..255)}"
      event.user_agent = ["Mozilla/5.0 (iPhone)", "Mozilla/5.0 (Windows NT 10.0)", "Mozilla/5.0 (Macintosh)"].sample
      event.created_at = newsletter.sent_at + rand(1..72).hours
    end
  end

  # Simulate clicks for 20-40% of openers
  click_rate = rand(20..40) / 100.0
  clickers = openers.sample((openers.count * click_rate).to_i)

  clickers.each do |subscriber|
    # Each clicker clicks 1-3 links
    rand(1..3).times do
      EmailEvent.create!(
        newsletter: newsletter,
        subscriber: subscriber,
        event_type: EmailEvent::CLICK,
        metadata: { url: ["https://example.com/event", "https://example.com/donate", "https://example.com/learn-more"].sample },
        ip_address: "#{rand(1..255)}.#{rand(1..255)}.#{rand(1..255)}.#{rand(1..255)}",
        user_agent: ["Mozilla/5.0 (iPhone)", "Mozilla/5.0 (Windows NT 10.0)", "Mozilla/5.0 (Macintosh)"].sample,
        created_at: newsletter.sent_at + rand(1..72).hours
      )
    end
  end
end
puts "Created email tracking events for sent newsletters"

# Summary
puts ""
puts "Seeding complete!"
puts ""
puts "Demo credentials:"
puts "  Email: demo@righteousdispatch.com"
puts "  Password: password123"
puts ""
puts "Data summary:"
puts "  - #{user.newsletters.sent.count} sent newsletters"
puts "  - #{user.newsletters.scheduled.count} scheduled newsletters"
puts "  - #{user.newsletters.drafts.count} draft newsletters"
puts "  - #{user.subscribers.confirmed.count} confirmed subscribers"
puts "  - #{user.tags.count} tags"
puts "  - #{user.signup_forms.count} signup forms (#{user.signup_forms.active.count} active)"
puts "  - #{EmailEvent.opens.count} email opens tracked"
puts "  - #{EmailEvent.clicks.count} email clicks tracked"
puts "  - Welcome email: #{user.welcome_email_enabled? ? 'enabled' : 'disabled'}"
