# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

RighteousDispatch is a self-hosted email newsletter platform built with Ruby on Rails 8.1. It provides newsletter management, subscriber handling, public signup forms, and email analytics with tracking.

## Development Commands

```bash
# Start development server (Rails + Tailwind CSS watcher)
bin/dev

# Run full CI pipeline
bin/ci

# Run tests
bin/rails test                    # Unit and integration tests
bin/rails test:system             # System/browser tests
bin/rails test test/models/user_test.rb          # Single test file
bin/rails test test/models/user_test.rb:10       # Single test at line

# Linting and security
bin/rubocop                       # Ruby style (Rails Omakase)
bin/brakeman --quiet              # Security analysis
bin/bundler-audit                 # Gem vulnerability audit
bin/importmap audit               # JS dependency audit

# Database
bin/rails db:migrate
bin/rails db:seed
bin/rails db:seed:replant         # Reset and reseed
```

## Architecture

### Core Models

- **User** - Account with custom bcrypt auth (no Devise), has newsletters, subscribers, tags, signup_forms
- **Newsletter** - Rich text content via Action Text, status (draft/scheduled/sent), tag-based targeting
- **Subscriber** - Email recipients with confirmation/unsubscribe tokens, tagging support
- **Tag** - Segmentation labels for subscribers and newsletters
- **SignupForm** - Public embeddable forms with auto-tagging
- **EmailEvent** - Tracks opens/clicks for analytics

### Authentication

Custom authentication using `has_secure_password` with bcrypt. No Devise. Key patterns:
- `app/controllers/concerns/authentication.rb` - `current_user`, `require_authentication!`
- Token-based flows: email confirmation, password reset, remember me, unsubscribe

### Background Jobs

Solid Queue for job processing:
- `SendNewsletterJob` - Batch newsletter sending
- `SendNewsletterEmailJob` - Individual email dispatch
- `ProcessScheduledNewslettersJob` - Scheduled newsletter processor

### Routes Structure

- `/session`, `/registration`, `/password`, `/confirmation` - Auth flows
- `/dashboard` - Authenticated landing
- `/newsletters` - CRUD with preview, send, schedule actions
- `/subscribers` - CRUD with import functionality
- `/tags`, `/signup_forms` - Management
- `/subscribe/:id`, `/unsubscribe/:token` - Public subscriber actions
- `/t/o/:token`, `/t/c/:token` - Email tracking pixels

## Frontend Stack

- **Hotwire** (Turbo + Stimulus) for interactivity
- **Tailwind CSS 4.1 + DaisyUI 5.5** with custom themes
- **Action Text** (Trix) for rich text editing
- **Propshaft** asset pipeline

### Design System

See `DESIGN.md` for complete patterns. Key principles:
- Dense information architecture (Bloomberg Terminal aesthetic)
- Mobile-first responsive: default < 640px, `sm:` 640px+, `lg:` 1024px+
- Two DaisyUI themes: `righteousfellowship` (light) and `righteousfellowship-dark`
- No rounded corners, shadows, or gradients - use sharp edges and borders
- Typography: `text-[10px] sm:text-xs` pattern for responsive scaling

## Deployment

Kamal-based Docker deployment to single DigitalOcean server. Configuration in `config/deploy.yml`.
