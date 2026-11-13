import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  prepare(event) {
    const trigger = event.relatedTarget
    if (!trigger?.dataset.deleteUrl) return

    const form = this.element.querySelector("form")
    this.element.querySelector("[data-delete-name]").textContent = trigger.dataset.categoryName
    form.action = trigger.dataset.deleteUrl
    form.querySelector("button").disabled = false
  }
}
