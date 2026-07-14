module App::NavbarHelper
  NavItem = Struct.new(:key, :path, :policy_action, :icon, :submenu, keyword_init: true)

  def app_nav_items
    commerce_policy = policy(current_user.commerce)
    [
      NavItem.new(key: "orders", path: app_orders_path, policy_action: :view_orders?, icon: "receipt"),
      NavItem.new(
        key: "products",
        policy_action: :view_products?,
        icon: "boxes-stacked",
        submenu: [
          { key: "product_categories", path: app_product_categories_path },
          { key: "product_variants",   path: app_product_variants_path },
          { key: "product_modifiers",  path: app_product_modifiers_path }
        ]
      ),
      NavItem.new(
        key: "settings",
        policy_action: :settings?,
        icon: "gear",
        submenu: [
          { key: "tables", path: app_settings_tables_path },
          { key: "appearance", path: app_settings_appearance_path }
        ]
      )
    ].select { |item| commerce_policy.public_send(item.policy_action) }
  end

  def nav_item_label(item)
    safe_join([ icon(item.icon, class: "text-sm"), t("app.nav.#{item.key}") ])
  end
end
