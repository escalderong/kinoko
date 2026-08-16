# Re-runnable: clears out any commerces from a previous seed run before
# rebuilding them, so `bin/rails db:seed` is safe to run repeatedly in dev.
#
# Plain #destroy_all won't do here: ProductCategory/Table declare
# dependent: :restrict_with_error on their own children (see CLAUDE.md /
# app/models), which silently no-ops a parent's dependent: :destroy cascade
# the moment it reaches a populated category or table instead of raising —
# so a Commerce with real menu data would never actually get deleted. Delete
# leaf-to-root with #delete_all instead, which skips callbacks entirely.
SEEDED_COMMERCE_NAMES = [ "La Parrilla del Che", "Café Aurora" ].freeze

def wipe_seeded_commerces!
  commerces = Commerce.where(name: SEEDED_COMMERCE_NAMES)
  return if commerces.none?

  tables = Table.where(commerce: commerces)
  products = Product.where(commerce: commerces)
  variant_groups = VariantGroup.where(product: products)
  modifier_groups = ModifierGroup.where(product: products)
  orders = Order.where(table: tables)
  order_items = OrderItem.where(order: orders)
  checks = Check.where(order: orders)

  OrderItemVariant.where(order_item: order_items).delete_all
  OrderItemModifier.where(order_item: order_items).delete_all
  CheckItem.where(check: checks).delete_all
  order_items.delete_all
  checks.delete_all
  orders.delete_all
  Variant.where(variant_group: variant_groups).delete_all
  Modifier.where(modifier_group: modifier_groups).delete_all
  variant_groups.delete_all
  modifier_groups.delete_all
  products.delete_all
  ProductCategory.where(commerce: commerces).delete_all
  tables.delete_all
  FloorZone.where(commerce: commerces).delete_all
  User.where(commerce: commerces).delete_all
  commerces.delete_all
end

wipe_seeded_commerces!

STAFF_ROLES = { owner: "Propietario", admin: "Administrador", waiter: "Mesero", cashier: "Cajero" }.freeze

def seed_staff!(commerce, slug)
  STAFF_ROLES.each do |role, label|
    User.create!(
      commerce: commerce,
      name: "#{label} Demo",
      email: "#{role}@#{slug}.test",
      password: "password123",
      role: role
    )
  end
end

def seed_tables!(commerce, zone, specs)
  specs.each do |spec|
    Table.create!(
      commerce: commerce, floor_zone: zone, number: spec[:number], capacity: spec[:capacity],
      status: :available, pos_x: spec[:x], pos_y: spec[:y], width: spec.fetch(:w, 2), height: spec.fetch(:h, 2)
    )
  end
end

def seed_product!(category, name:, price:, variant_groups: [], modifier_groups: [])
  product = category.products.create!(
    commerce: category.commerce, name: name, base_price: Money.from_amount(price, "COP")
  )

  variant_groups.each do |vg|
    group = product.variant_groups.create!(name: vg[:group_name], is_required: vg.fetch(:required, false))
    vg[:options].each do |option_name, delta|
      group.variants.create!(
        name: option_name, sku: "#{product.name}-#{option_name}".parameterize.upcase,
        price_delta: Money.from_amount(delta, "COP")
      )
    end
  end

  modifier_groups.each do |mg|
    group = product.modifier_groups.create!(
      name: mg[:group_name], is_required: mg.fetch(:required, false),
      min_selected: mg.fetch(:min, 0), max_selected: mg[:max]
    )
    mg[:options].each do |option_name, delta|
      group.modifiers.create!(name: option_name, price_delta: Money.from_amount(delta, "COP"))
    end
  end

  product
end

# ---------------------------------------------------------------------------
# La Parrilla del Che — Colombian grill restaurant
# ---------------------------------------------------------------------------

parrilla = Commerce.create!(name: "La Parrilla del Che", theme: "coffee")
seed_staff!(parrilla, "parrilla")

platos = parrilla.product_categories.create!(name: "Platos Fuertes", icon: "drumstick-bite")
seed_product!(platos, name: "Bandeja Paisa", price: 38_000)
seed_product!(
  platos, name: "Churrasco a la Parrilla", price: 45_000,
  variant_groups: [
    { group_name: "Tamaño", required: true, options: { "Individual" => 0, "Para compartir" => 25_000 } }
  ],
  modifier_groups: [
    { group_name: "Acompañamientos extra", max: 2, options: { "Papa extra" => 5_000, "Chorizo extra" => 6_000 } }
  ]
)
seed_product!(
  platos, name: "Pechuga a la Plancha", price: 30_000,
  modifier_groups: [
    { group_name: "Extras", options: { "Queso extra" => 3_000, "Tocineta" => 4_000 } }
  ]
)

bebidas = parrilla.product_categories.create!(name: "Bebidas", icon: "bottle-water")
seed_product!(
  bebidas, name: "Limonada Natural", price: 8_000,
  variant_groups: [
    { group_name: "Tamaño", required: true, options: { "Pequeña" => 0, "Grande" => 3_000 } }
  ]
)
seed_product!(bebidas, name: "Coca-Cola", price: 6_000)
seed_product!(bebidas, name: "Cerveza Artesanal", price: 12_000)

postres = parrilla.product_categories.create!(name: "Postres", icon: "cake-candles")
seed_product!(postres, name: "Flan de Caramelo", price: 9_000)
seed_product!(
  postres, name: "Tres Leches", price: 10_000,
  modifier_groups: [
    { group_name: "Toppings", max: 1, options: { "Fresas" => 2_000, "Arequipe" => 1_500 } }
  ]
)

salon = parrilla.floor_zones.create!(name: "Salón Principal", position: 0)
seed_tables!(parrilla, salon, [
  { number: 1, capacity: 4, x: 0, y: 0 },
  { number: 2, capacity: 2, x: 3, y: 0 },
  { number: 3, capacity: 6, x: 0, y: 3, w: 3 }
])
terraza = parrilla.floor_zones.create!(name: "Terraza", position: 1)
seed_tables!(parrilla, terraza, [
  { number: 4, capacity: 4, x: 0, y: 0 },
  { number: 5, capacity: 4, x: 3, y: 0 }
])

# ---------------------------------------------------------------------------
# Café Aurora — neighborhood coffee shop
# ---------------------------------------------------------------------------

aurora = Commerce.create!(name: "Café Aurora", theme: "caramellatte")
seed_staff!(aurora, "aurora")

cafe = aurora.product_categories.create!(name: "Café", icon: "mug-saucer")
seed_product!(cafe, name: "Espresso", price: 5_000)
seed_product!(
  cafe, name: "Latte", price: 8_000,
  variant_groups: [
    { group_name: "Tamaño", required: true, options: { "Pequeño" => 0, "Mediano" => 2_000, "Grande" => 4_000 } }
  ],
  modifier_groups: [
    { group_name: "Tipo de leche", max: 1, options: { "Leche de almendra" => 2_000, "Leche de avena" => 2_500 } }
  ]
)
seed_product!(cafe, name: "Capuchino", price: 8_500)

pasteleria = aurora.product_categories.create!(name: "Pastelería", icon: "cookie")
seed_product!(pasteleria, name: "Croissant", price: 6_000)
seed_product!(
  pasteleria, name: "Muffin de Arándanos", price: 7_000,
  modifier_groups: [
    { group_name: "Extras", options: { "Chips de chocolate" => 1_000 } }
  ]
)

sandwiches = aurora.product_categories.create!(name: "Sándwiches", icon: "bread-slice")
seed_product!(
  sandwiches, name: "Club Sandwich", price: 18_000,
  modifier_groups: [
    { group_name: "Extras", max: 2, options: { "Aguacate" => 3_000, "Tocineta" => 4_000 } }
  ]
)
seed_product!(sandwiches, name: "Sandwich Vegetariano", price: 15_000)

salon_aurora = aurora.floor_zones.create!(name: "Salón", position: 0)
seed_tables!(aurora, salon_aurora, [
  { number: 1, capacity: 2, x: 0, y: 0 },
  { number: 2, capacity: 4, x: 3, y: 0 },
  { number: 3, capacity: 2, x: 0, y: 3 }
])

puts "Seeded #{Commerce.count} commerces, #{User.count} users, #{Product.count} products, #{Table.count} tables."
