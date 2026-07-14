require "rails_helper"

RSpec.describe IconsHelper, type: :helper do
  describe "#icon" do
    it "renders an <i> tag with the solid style by default" do
      result = helper.icon("plus")

      expect(result).to have_css("i.fa-solid.fa-plus", visible: :all)
    end

    it "supports overriding the style" do
      result = helper.icon("github", style: :brands)

      expect(result).to have_css("i.fa-brands.fa-github", visible: :all)
    end

    it "passes through extra classes and html attributes" do
      result = helper.icon("trash", class: "text-error", data: { test: "delete-icon" })

      expect(result).to have_css("i.fa-solid.fa-trash.text-error[data-test='delete-icon']", visible: :all)
    end

    it "defaults to aria-hidden true" do
      result = helper.icon("plus")

      expect(result).to have_css("i[aria-hidden='true']", visible: :all)
    end

    it "raises for an unknown style" do
      expect { helper.icon("plus", style: :bogus) }.to raise_error(ArgumentError)
    end
  end
end
