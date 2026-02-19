import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "editor", "textarea", "originalContent", "editButton"]

  edit() {
    this.displayTarget.classList.add("hidden")
    this.editButtonTarget.classList.add("hidden")
    this.editorTarget.classList.remove("hidden")
  }

  cancel() {
    this.textareaTarget.value = this.originalContentTarget.value
    this.editorTarget.classList.add("hidden")
    this.displayTarget.classList.remove("hidden")
    this.editButtonTarget.classList.remove("hidden")
  }
}
