import { Controller } from "@hotwired/stimulus"

// Keeps the <html data-theme> attribute in sync with the commerce theme across
// Turbo Drive visits. Turbo replaces <body> on every navigation but preserves
// <html> and its attributes, so a theme change would otherwise only take effect
// after a full reload. This controller lives on <body>; Stimulus fires
// nameValueChanged() on initial connect (and on any later change), so it
// re-applies the current theme to the document root on every Turbo visit.
export default class extends Controller {
  static values = { name: String }

  nameValueChanged() {
    if (this.nameValue) {
      document.documentElement.dataset.theme = this.nameValue
    }
  }
}
