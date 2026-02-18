import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["clientName", "toggleButton"]

  connect() {
    this.visible = localStorage.getItem("clientNameVisible") === "true"
    this.render()
  }

  toggle() {
    this.visible = !this.visible
    localStorage.setItem("clientNameVisible", this.visible)
    this.render()
  }

  render() {
    this.clientNameTargets.forEach(el => {
      el.classList.toggle("hidden", !this.visible)
    })

    if (this.hasToggleButtonTarget) {
      this.toggleButtonTarget.classList.toggle("text-warm-400", this.visible)
      this.toggleButtonTarget.classList.toggle("border-warm-500/30", this.visible)
      this.toggleButtonTarget.classList.toggle("text-gray-400", !this.visible)
      this.toggleButtonTarget.classList.toggle("border-white/10", !this.visible)
    }
  }
}
