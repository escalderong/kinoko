require 'rails_helper'

RSpec.describe App::NavigationHelper, type: :helper do
  before do
    helper.extend(Pundit::Authorization)
    allow(helper).to receive(:pundit_user).and_return(current_user)
  end

  let(:current_user) { owner }
  let(:commerce) { create(:commerce) }
  let(:owner) { build(:user, role: :owner, commerce: commerce) }
  let(:waiter) { build(:user, role: :waiter, commerce: commerce) }

  describe "#app_menu_items" do
    subject(:items) { helper.app_menu_items(owner, commerce) }

    it "includes top-level items for Orders, Tables, Products, Settings, and Users" do
      labels = items.map(&:label)

      expect(labels).to include(:orders, :tables, :products, :settings, :users)
    end

    it "Products item has a non-empty submenu with Categories, Variants, and Modifiers" do
      products_item = items.find { |item| item.label == :products }

      expect(products_item.submenu).not_to be_empty
      expect(products_item.submenu.map(&:label)).to contain_exactly(
        :product_categories, :product_variants, :product_modifiers
      )
    end

    it "returns MenuItem structs" do
      expect(items).to all(be_a(App::NavigationHelper::MenuItem))
    end
  end

  describe "#menu_item_visible?" do
    let(:item_without_policy) do
      App::NavigationHelper::MenuItem.new(label: :orders, path: :app_orders_path, icon: "list", policy: nil, submenu: nil)
    end

    it "returns true when the item has no policy" do
      expect(helper.menu_item_visible?(item_without_policy, view: helper)).to be true
    end

    context "when the item is gated by CommercePolicy#settings?" do
      let(:item) do
        App::NavigationHelper::MenuItem.new(
          label: :settings, path: :app_settings_path, icon: "cog",
          policy: [ commerce, :settings? ], submenu: nil
        )
      end

      it "is visible for an owner" do
        expect(helper.menu_item_visible?(item, view: helper)).to be true
      end

      context "when the user is a waiter" do
        let(:current_user) { waiter }

        it "is not visible" do
          expect(helper.menu_item_visible?(item, view: helper)).to be false
        end
      end
    end

    context "when the item is gated by CommercePolicy#manage_users?" do
      let(:item) do
        App::NavigationHelper::MenuItem.new(
          label: :users, path: :app_users_path, icon: "users",
          policy: [ commerce, :manage_users? ], submenu: nil
        )
      end

      it "is visible for an owner" do
        expect(helper.menu_item_visible?(item, view: helper)).to be true
      end

      context "when the user is a waiter" do
        let(:current_user) { waiter }

        it "is not visible" do
          expect(helper.menu_item_visible?(item, view: helper)).to be false
        end
      end
    end
  end
end
