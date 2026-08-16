# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
bin/setup                  # Install dependencies, prepare the DB, and start dev server
bin/dev                    # Start development server (rails server)
bin/rails db:prepare       # Create/migrate the database (idempotent)
bin/rails db:migrate       # Run pending migrations
bundle exec rspec          # Run all specs
bundle exec rspec spec/path/to/spec_file.rb  # Run a single spec file
bin/rubocop                # Lint (rubocop-rails-omakase style)
bin/brakeman --no-pager    # Static security analysis
bin/importmap audit        # JS dependency security scan
```

## Architecture

**Kinoko** is a restaurant POS (Point of Sale) Rails 8 application backed by **PostgreSQL via ActiveRecord**. Primary keys are UUIDs (`gen_random_uuid()`, native on Postgres 13+ — no `pgcrypto` extension needed). Status/role fields use native ActiveRecord `enum`.

**Key gems:** Devise (auth), Pundit (authorization), money-rails (`monetize` on `*_cents` columns), strong_migrations (guards unsafe migrations), Hotwire (Turbo + Stimulus), importmap-rails, Propshaft (asset pipeline).

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
Order → Checks (subtotal/tax/tip: Money, status: open/paid)
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

- Generate migrations via the CLI (`bin/rails generate migration ...`), never hand-write a migration file from scratch. Declare foreign keys inline inside `create_table` (`t.references ..., foreign_key: true`) — `strong_migrations` does not exempt standalone `add_foreign_key` calls the way it exempts `add_index` on new tables.
- `strong_migrations` runs on every migration (`StrongMigrations.start_after = 0` in `config/initializers/strong_migrations.rb`) — follow the safe-migration pattern it suggests rather than bypassing it.
- All queries must be scoped to the current Commerce as this would be a security risk.
- Avoid changing denormalized data structures (e.g. OrderItem fields).
- Prefer Turbo + Stimulus over custom JavaScript frameworks.
- Do not introduce new gems without clear justification.
- Do not use ViewComponents nor Presenters nor Draper, stick to Rails conventions, like partials and helpers (don't abuse helpers)

## Visual Style Guide

- Every view should be constructed using only daisyUI and its skill
- daisyUI documentation can be found at https://daisyui.com/docs/use/
- The whole app is themed by each commerce, so only use semantic color utility classes (e.g. `bg-primary`, `text-secondary`) instead of constant colors, always based on daisyUI's theme system (https://daisyui.com/docs/colors/)