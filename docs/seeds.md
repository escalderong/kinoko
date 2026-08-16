# Seed data

`db/seeds.rb` builds two demo commerces so the app has realistic data to click through in development — staff logins for every role, a varied menu, and a floor plan. It creates no orders or checks.

## Usage

```bash
bin/rails db:seed
```

Safe to run repeatedly — it wipes and rebuilds its own two commerces each time (see [Re-running / cleanup](#re-running--cleanup)), so it won't pile up duplicates or drift from the file's current content.

## What gets created

| | La Parrilla del Che | Café Aurora |
|---|---|---|
| Theme | `coffee` | `caramellatte` |
| Categories | Platos Fuertes, Bebidas, Postres | Café, Pastelería, Sándwiches |
| Products | 8, including one with both a required variant group and modifiers | 7, including one with a required variant group and a modifier group |
| Floor zones | Salón Principal, Terraza | Salón |
| Tables | 5 | 3 |

Each commerce gets 4 users, one per role, logging in as `<role>@<slug>.test` (`owner@parrilla.test`, `admin@aurora.test`, etc.) with password `password123`.

Menu items intentionally cover the different product shapes the schema supports:

- Plain products with no options (`Coca-Cola`, `Espresso`)
- A required variant group, i.e. the customer must pick one (`Churrasco a la Parrilla` → Tamaño: Individual / Para compartir)
- Optional modifier groups with a `max_selected` cap (`Tres Leches` → Toppings, pick up to 1)
- Both on the same product (`Latte` → required Tamaño variant group + optional Tipo de leche modifier group)

Prices are built with `Money.from_amount(pesos, "COP")` rather than the raw-cents `Money.new(...)` shorthand the test factories use — `from_amount` takes major units directly, so `Money.from_amount(45_000, "COP")` reads as (and renders as) forty-five thousand pesos instead of needing the caller to multiply by 100 in their head.

## Re-running / cleanup

The file starts by deleting any existing "La Parrilla del Che" / "Café Aurora" data before rebuilding it, scoped by commerce so it never touches other data in your dev DB.

That cleanup is **not** `Commerce.where(...).destroy_all`. `ProductCategory` and `Table` declare `dependent: :restrict_with_error` on their own children (`has_many :products`, `has_many :orders` — see `CLAUDE.md`), and in this Rails version that restriction silently no-ops a *parent's* `dependent: :destroy` cascade the moment it reaches a populated category or table, instead of raising. A `Commerce` with real menu data would `destroy_all` without actually deleting anything, then the next line would blow up on a duplicate-email `RecordInvalid` when it tried to recreate staff — which is exactly what happened while writing this file. The seed script instead deletes leaf-to-root with plain `#delete_all` (`wipe_seeded_commerces!` in `db/seeds.rb`), which skips callbacks and the restrict checks entirely.

If you ever need to wipe them without reseeding: run `bin/rails runner db/seeds.rb`'s cleanup manually, or just `bin/rails db:seed` again — the rebuild is the point.

## Extending

`seed_product!` and `seed_tables!` are small builders local to this file, not app code — they exist to keep the product/table definitions declarative. To add a product:

```ruby
seed_product!(
  platos, name: "Nuevo Plato", price: 25_000,
  variant_groups: [
    { group_name: "Tamaño", required: true, options: { "Individual" => 0, "Grande" => 8_000 } }
  ],
  modifier_groups: [
    { group_name: "Extras", max: 2, options: { "Queso" => 3_000 } }
  ]
)
```

`variant_groups:` and `modifier_groups:` are both optional — omit either (or both) for a plain product. Modifier group keys: `required:` (default `false`), `min:` (default `0`), `max:` (default `nil`, unbounded).
