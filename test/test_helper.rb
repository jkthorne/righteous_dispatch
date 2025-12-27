ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Sign in helper for integration tests (posts to session path)
    def sign_in(user, password: "password123")
      post session_path, params: { email: user.email, password: password }
    end

    # Sign out helper for integration tests
    def sign_out
      delete session_path
    end

    # Generate tracking token for tests
    def generate_tracking_token(newsletter:, subscriber:)
      Rails.application.message_verifier(:tracking).generate(
        { newsletter_id: newsletter.id, subscriber_id: subscriber.id },
        expires_in: 1.year
      )
    end
  end
end

# Controller test helper for setting session directly
module ActionDispatch
  class IntegrationTest
    def sign_in_as(user, password: "password123")
      post session_path, params: { email: user.email, password: password }
    end
  end
end
