module App
  module NavigationHelper
    # label: i18n key under app.nav.* used for the link text
    # path: route helper symbol, called on the view to build the URL
    # icon: icon identifier, rendered by the menu item partial
    # policy: nil (always visible) or a [record, action] pair checked via Pundit
    # submenu: nil/[] for leaf items, or an array of nested MenuItem entries
    MenuItem = Struct.new(:label, :path, :icon, :policy, :submenu, keyword_init: true)

    def app_menu_items(user, commerce)
      [
        MenuItem.new(label: :orders, path: :app_orders_path, icon: "clipboard-document-list", policy: nil, submenu: nil),
        MenuItem.new(label: :tables, path: :app_tables_path, icon: "table-cells", policy: nil, submenu: nil),
        MenuItem.new(
          label: :products, path: nil, icon: "shopping-bag", policy: nil,
          submenu: [
            MenuItem.new(label: :product_categories, path: :app_product_categories_path, icon: "tag", policy: nil, submenu: nil),
            MenuItem.new(label: :product_variants, path: :app_product_variants_path, icon: "squares-2x2", policy: nil, submenu: nil),
            MenuItem.new(label: :product_modifiers, path: :app_product_modifiers_path, icon: "adjustments-horizontal", policy: nil, submenu: nil)
          ]
        ),
        MenuItem.new(label: :settings, path: :app_settings_path, icon: "cog-6-tooth", policy: [ commerce, :settings? ], submenu: nil),
        MenuItem.new(label: :users, path: :app_users_path, icon: "users", policy: [ commerce, :manage_users? ], submenu: nil)
      ]
    end

    def menu_item_visible?(item, view:)
      return true if item.policy.nil?

      record, action = item.policy
      view.policy(record).public_send(action)
    end
  end
end
