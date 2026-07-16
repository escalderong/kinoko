import { Controller } from "@hotwired/stimulus"

// Keeps navbar dropdowns/submenus mutually exclusive: clicking anywhere
// that isn't inside a given open menu closes it — whether that's another
// menu opening or a click outside all of them. Mixes two native toggle
// mechanisms (CSS-focus dropdowns and <details>), neither of which closes
// on its own when a sibling of a different kind opens or on outside click.
export default class extends Controller {
  connect() {
    this.onClick = this.onClick.bind(this)
    document.addEventListener("click", this.onClick, true)
  }

  disconnect() {
    document.removeEventListener("click", this.onClick, true)
  }

  onClick(event) {
    this.element.querySelectorAll(".dropdown, details").forEach((menu) => {
      if (this.isOpen(menu) && !menu.contains(event.target)) this.close(menu)
    })
  }

  isOpen(menu) {
    return menu.matches("details") ? menu.open : menu.contains(document.activeElement)
  }

  close(menu) {
    if (menu.matches("details")) {
      menu.open = false
    } else {
      document.activeElement.blur()
    }
  }
}
