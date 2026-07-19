import { Controller } from "@hotwired/stimulus"

// Radio inputs can't be unchecked by clicking them again natively.
// This tracks whether an input was already checked before the click
// so a second click on the open item can force it closed.
export default class extends Controller {
  static targets = ["input"]

  markState(event) {
    event.target.dataset.wasChecked = event.target.checked
  }

  toggle(event) {
    const input = event.target
    if (input.dataset.wasChecked === "true") input.checked = false
  }
}
