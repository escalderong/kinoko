# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
bin/setup                  # Install dependencies and start dev server
bin/dev                    # Start development server (rails server)
bin/rails test             # Run all tests
bin/rails test test/path/to/test_file.rb  # Run a single test file
bin/rails test:system      # Run system tests (uses Capybara + Selenium)
bin/rails db:test:prepare  # Prepare test database
bin/rubocop                # Lint (rubocop-rails-omakase style)
bin/brakeman --no-pager    # Static security analysis
bin/importmap audit        # JS dependency security scan
```

## Architecture

**Kinoko** is a restaurant POS (Point of Sale) Rails 8 application backed by **MongoDB via Mongoid** — ActiveRecord is not used at all (it's commented out in `config/application.rb`). All models use `include Mongoid::Document`.

All Mongo documentation is found [here](https://www.mongodb.com/docs/)

**Key gems:** Devise (auth), Pundit (authorization), money-rails (Money type on price fields), Hotwire (Turbo + Stimulus), importmap-rails, Propshaft (asset pipeline).

### Multi-tenancy

`Commerce` is the top-level tenant. Users, Tables, and ProductCategories all belong to a Commerce.

All controllers and their actions are scoped to a Commerce. This is handled via a before_action in the ApplicationController.
All controllers and their actions must validate authorization via Pundit policies.

### Domain model

```
Commerce
├── Users (roles: owner, admin, waiter)
├── Tables (status: available/reserved/occupied)
└── ProductCategories
    └── Products (base_price: Money, is_active)
        ├── VariantGroups (is_required) → Variants
        └── ModifierGroups (is_required, min/max_selected) → Modifiers

Table → Orders (status: open/closed)
Order → OrderItems (denormalized: stores product_name + base_price at time of order)
     │   ├── OrderItemVariants
     │   └── OrderItemModifiers
Order → Tickets (subtotal/tax/tip: Money, status: open/paid)
```

**OrderItem intentionally denormalizes product data** (stores `product_name` and `base_price` directly) so historical orders are not affected by future product changes.

### Auth & Authorization

- Authentication via Devise on the `User` model (`database_authenticatable`, `rememberable`, `validatable`)
- Authorization via Pundit (policy files in `app/policies/`)
- Routes include `devise_for :users`

### Localization

- The aim is to have the whole app available in Spanish and English
- Localization is handled via I18n (translations in `config/locales/`)
- Whenever you add a new string to translate, add it to both `config/locales/en.yml` and `config/locales/es.yml`

### App development objectives

- Modern design is expected by users, this includes but is not limited to:
  - Clean, minimal, and responsive UI
  - Smooth animations and transitions
  - SPA-like experience
  - Responsive layouts since it will be used on very different devices
  - Dark mode availability
  - Drag and drop features

- Prefer Turbo Frames over full-page reloads
- Prefer Stimulus controllers over custom JS files

- Service objects vs fat models:
  - Use Service Objects for logic that might be complex and it's worth extracting for reusability across controllers, CLI, jobs, etc.
  - Controllers should focus on handling requests and responses

- Error handling:
  - Services should raise errors when something goes wrong
  - Controllers should catch errors with application_controller level rescue blocks and render appropriate responses in the UI via flash messages or redirects when appropriate

## Conventions & Constraints

- Do not use ActiveRecord, migrations, or SQL.
- All queries must be scoped to the current Commerce as this would be a security risk.
- Avoid changing denormalized data structures (e.g. OrderItem fields).
- Prefer Turbo + Stimulus over custom JavaScript frameworks.
- Do not introduce new gems without clear justification.