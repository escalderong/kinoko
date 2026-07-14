module IconsHelper
  FA_STYLE_PREFIXES = { solid: "fa-solid", regular: "fa-regular", brands: "fa-brands" }.freeze

  def icon(name, style: :solid, **html_attrs)
    prefix = FA_STYLE_PREFIXES.fetch(style) { raise ArgumentError, "Unknown icon style: #{style.inspect}" }
    css_class = html_attrs.delete(:class)
    tag.i(class: class_names(prefix, "fa-#{name}", css_class), "aria-hidden": true, **html_attrs)
  end
end
