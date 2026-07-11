module IconsHelper
  def icon(name, css_class: "h-5 w-5")
    render "shared/icons/#{name}", css_class: css_class
  end
end
