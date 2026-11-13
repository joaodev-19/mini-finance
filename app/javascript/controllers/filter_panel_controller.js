import { Controller } from "@hotwired/stimulus"

// Native details works without JavaScript; these are desktop dropdown conveniences.
export default class extends Controller {
  close(event) {
    if (!this.element.open) return
    event.preventDefault()
    this.element.open = false
    this.element.querySelector("summary").focus()
  }

  dismiss(event) {
    if (window.matchMedia("(max-width: 991.98px)").matches) return
    if (!this.element.contains(event.target)) this.element.open = false
  }
}
