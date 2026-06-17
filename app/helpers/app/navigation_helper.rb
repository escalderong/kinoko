module App
  module NavigationHelper
    # label: i18n key under app.nav.* used for the link text
    # path: route helper symbol, called on the view to build the URL
    # policy: nil (always visible) or a [record, action] pair checked via Pundit
    # submenu: nil/[] for leaf items, or an array of nested MenuItem entries
    MenuItem = Struct.new(:label, :path, :policy, :submenu, keyword_init: true)

    def app_menu_items(user, commerce)
      [
        MenuItem.new(label: :orders, path: :app_orders_path, policy: nil, submenu: nil),
        MenuItem.new(label: :tables, path: :app_tables_path, policy: nil, submenu: nil),
        MenuItem.new(
          label: :products, path: nil, policy: nil,
          submenu: [
            MenuItem.new(label: :product_categories, path: :app_product_categories_path, policy: nil, submenu: nil),
            MenuItem.new(label: :product_variants, path: :app_product_variants_path, policy: nil, submenu: nil),
            MenuItem.new(label: :product_modifiers, path: :app_product_modifiers_path, policy: nil, submenu: nil)
          ]
        ),
        MenuItem.new(label: :settings, path: :app_settings_path, policy: [ commerce, CommercePolicy::SECTION_AUTHORIZATIONS["settings"] ], submenu: nil),
        MenuItem.new(label: :users, path: :app_users_path, policy: [ commerce, CommercePolicy::SECTION_AUTHORIZATIONS["users"] ], submenu: nil)
      ]
    end

    def menu_item_visible?(item, view:)
      return true if item.policy.nil?

      record, action = item.policy
      view.policy(record).public_send(action)
    end
  end
end
