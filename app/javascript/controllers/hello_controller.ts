import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log('Hello from hello_controller.ts')
    this.element.textContent = "Hello World!"
  }
}
