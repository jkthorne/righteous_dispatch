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
