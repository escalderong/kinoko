require "rails_helper"

RSpec.describe App::TablesHelper, type: :helper do
  describe "#order_item_option_label" do
    it "returns just the group and name when there is no price delta" do
      label = helper.order_item_option_label("Leche", "Entera", Money.new(0, "COP"))

      expect(label).to eq("Leche: Entera")
    end

    it "appends the formatted price delta when it is non-zero" do
      label = helper.order_item_option_label("Leche", "Almendras", Money.new(150_000, "COP"))

      expect(label).to eq("Leche: Almendras (+#{Money.new(150_000, 'COP').format})")
    end
  end
end
