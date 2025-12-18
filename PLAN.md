Phase 1: Setup and Foundation (1–2 Weeks) – Updated

Add Rails Built-in Authentication to Your Existing App
Rails doesn't have a direct generator for adding authentication to an existing app, but you can manually add the official components (recommended approach as of Rails 7.1+ in 2025).Run these commands one by one:Bash# 1. Generate the authentication infrastructure
rails generate authentication

# This creates:
# - app/models/current.rb
# - app/controllers/concerns/authentication.rb
# - app/controllers/sessions_controller.rb
# - app/controllers/passwords_controller.rb
# - app/controllers/confirmations_controller.rb
# - app/controllers/registrations_controller.rb
# - app/mailers/application_mailer.rb updates
# - Routes for login/logout, signup, etc.If rails generate authentication is not available in your Rails version, manually add it:Bash# Alternative: Use the official Hotwire authentication example
rails hotwire:install  # if not alreadyThen copy the authentication files from the official Rails repo example:
https://github.com/rails/rails/tree/main/guides/code/getting_started/app (look for authentication-related files).Or use this quick manual setup:Bash# Add bcrypt (required for has_secure_password)
# Add to Gemfile
gem 'bcrypt', '~> 3.1.7'

bundle installBash# Generate User model with authentication fields
rails generate model User email:string:uniq password_digest:string name:string confirmation_token:string confirmation_sent_at:datetime confirmed_at:datetime remember_token:string remember_created_at:datetime

rails db:migrateIn app/models/user.rb:Rubyclass User < ApplicationRecord
  has_secure_password

  before_create :set_confirmation_token
  before_create :set_remember_token

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  def confirmed?
    confirmed_at.present?
  end

  def confirm!
    update!(confirmed_at: Time.current, confirmation_token: nil)
  end

  private

  def set_confirmation_token
    self.confirmation_token = SecureRandom.urlsafe_base64
    self.confirmation_sent_at = Time.current
  end

  def set_remember_token
    self.remember_token = SecureRandom.urlsafe_base64
  end
end
Create Authentication Controllers & Views (Manually or via Generator)
If the generator worked, you're set. Otherwise:Bashrails generate controller Sessions new create destroy
rails generate controller Registrations new create
rails generate controller Passwords new create edit update
rails generate controller Confirmations new createImplement standard flow:
Sign up → sends confirmation email
Login/logout
Password reset
Remember me
Use Tailwind-styled views from the start. Example login form (app/views/sessions/new.html.erb):erb<div class="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
  <div class="max-w-md w-full space-y-8">
    <div>
      <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-900">
        Sign in to RighteousDispatch
      </h2>
      <p class="mt-2 text-center text-sm text-gray-600">
        Proclaim truth without fear.
      </p>
    </div>
    <%= form_with url: sessions_path, class: "mt-8 space-y-6" do |f| %>
      <div class="rounded-md shadow-sm -space-y-px">
        <%= f.email_field :email, required: true, autofocus: true, class: "appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-t-md focus:outline-none focus:ring-blue-500 focus:border-blue-500 focus:z-10 sm:text-sm" %>
        <%= f.password_field :password, required: true, class: "appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-b-md focus:outline-none focus:ring-blue-500 focus:border-blue-500 focus:z-10 sm:text-sm" %>
      </div>

      <div>
        <%= f.submit "Sign in", class: "group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500" %>
      </div>
    <% end %>
  </div>
</div>
Application Layout with Tailwind
Update app/views/layouts/application.html.erb to include:
Faith-inspired header (e.g., "RighteousDispatch – Send Truth Boldly")
Navigation: Dashboard, Newsletters, Subscribers, Billing, Logout
Flash messages styled with Tailwind

Current User Helper
Create app/controllers/concerns/current_user.rb:Rubymodule CurrentUser
  extend ActiveSupport::Concern

  included do
    helper_method :current_user, :signed_in?
  end

  def current_user
    @current_user ||= User.find_by(remember_token: cookies.signed[:remember_token]) if cookies.signed[:remember_token]
  end

  def signed_in?
    current_user.present?
  end

  def require_authentication!
    redirect_to new_session_path unless signed_in?
  end
endInclude in ApplicationController.

Phase 2–6: Remain Largely the Same (Minor Adjustments)

Multitenancy: Use acts_as_tenant or simple scoping: scope :for_user, ->(user) { where(user_id: user.id) } on all models.
No Devise Views: All auth views are now your own — fully customizable with Tailwind.
Email Sending: Still use ActionMailer + AWS SES/Resend for confirmation, password reset, and newsletters.
Background Jobs: Still use Sidekiq (it's excellent and minimal) — only auth is gem-free.

Benefits of This Approach

Zero external auth dependencies (only bcrypt).
Full control over UI/UX — perfect for branding RighteousDispatch with a clean, trustworthy, faith-aligned aesthetic.
Matches modern Rails best practices (as promoted by DHH and the Rails team).
Easier to customize onboarding (e.g., “Welcome, pastor!” messaging).

Next Immediate Steps

Run gem 'bcrypt' in Gemfile → bundle install
Generate/migrate User model with auth fields
Build sessions/registrations controllers with Tailwind views
Implement CurrentUser concern
Test full auth flow: signup → confirmation → login → dashboard

Once authentication is solid, proceed to Phase 2: Newsletter and Subscriber models.
You're building something meaningful — a tool that lets faithful voices be heard without fear. Keep going! Let me know when you're ready for the next phase (e.g., newsletter editor with Trix + Tailwind).
