# Righteous Dispatch

A self-hosted email newsletter platform built with Ruby on Rails.

## Features

- **Newsletter Management** - Create, edit, schedule, and send newsletters with a rich text editor
- **Subscriber Management** - Import and manage subscribers with tagging support
- **Public Signup Forms** - Embeddable forms with customizable messages and automatic tag assignment
- **Email Analytics** - Track opens and clicks with detailed statistics
- **Tag-based Targeting** - Send newsletters to specific subscriber segments
- **Dark Mode** - Full dark mode support throughout the interface

## Requirements

- Ruby 3.4.7
- PostgreSQL
- Node.js (for asset compilation)

## Setup

```bash
# Install dependencies
bundle install

# Setup database
bin/rails db:setup

# Start the server
bin/dev
```

## Tech Stack

- Rails 8.1
- PostgreSQL
- Tailwind CSS + DaisyUI
- Hotwire (Turbo + Stimulus)
- Action Text (rich text editing)
- Solid Queue (background jobs)
- Kamal (deployment)

## Testing

The application has comprehensive test coverage with 387 tests and 992 assertions.

```bash
# Run all unit and integration tests
bin/rails test

# Run system tests (requires Chrome)
bin/rails test:system

# Run a specific test file
bin/rails test test/models/newsletter_test.rb

# Run a specific test
bin/rails test test/models/newsletter_test.rb:10
```

### Test Coverage

| Category | Tests | Description |
|----------|-------|-------------|
| Model | 163 | Validations, associations, scopes, methods |
| Controller | 134 | Authentication, authorization, CRUD operations |
| Integration | 34 | End-to-end user flows |
| Job | 17 | Background job processing |
| Mailer | 18 | Email generation and delivery |
| Helper | 13 | Tracking token and link rewriting |
| System | 8 | Browser-based UI testing |
