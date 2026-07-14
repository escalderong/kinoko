module App::FlashHelper
  FLASH_STYLES = {
    "notice" => { class: "alert-info", icon: "circle-info" },
    "info" => { class: "alert-info", icon: "circle-info" },
    "success" => { class: "alert-success", icon: "circle-check" },
    "warning" => { class: "alert-warning", icon: "triangle-exclamation" },
    "alert" => { class: "alert-error", icon: "circle-exclamation" },
    "error" => { class: "alert-error", icon: "circle-exclamation" }
  }.freeze

  def app_flash_messages
    flash.filter_map do |type, message|
      style = FLASH_STYLES[type.to_s]
      [ message, style ] if style
    end
  end
end
