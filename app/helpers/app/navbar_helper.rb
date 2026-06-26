module App::NavbarHelper
  NavItem = Struct.new(:key, :path, :policy_action, :icon, :submenu, keyword_init: true)

  ORDERS_ICON = "M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
  PRODUCTS_ICON = "M21 7.5l-9-5.25L3 7.5m18 0l-9 5.25m9-5.25v9l-9 5.25M3 7.5l9 5.25M3 7.5v9l9 5.25m0-9v9"

  def app_nav_items
    commerce_policy = policy(current_user.commerce)
    [
      NavItem.new(key: "orders", path: app_orders_path, policy_action: :view_orders?, icon: ORDERS_ICON),
      NavItem.new(
        key: "products",
        policy_action: :view_products?,
        icon: PRODUCTS_ICON,
        submenu: [
          { key: "product_categories", path: app_product_categories_path },
          { key: "product_variants",   path: app_product_variants_path },
          { key: "product_modifiers",  path: app_product_modifiers_path }
        ]
      )
    ].select { |item| commerce_policy.public_send(item.policy_action) }
  end
end
