import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["value"]

  choose(event) {
    this.valueTarget.textContent = event.target.value
    this.element.open = false
    this.element.querySelector("summary").focus({ preventScroll: true })
  }

  reveal() {
    if (this.element.open) {
      this.element.querySelector(".app-notebook-page-size-options").scrollIntoView({ block: "nearest", behavior: "instant" })
    }
  }
}
