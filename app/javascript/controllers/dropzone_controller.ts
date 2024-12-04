import { Controller } from "@hotwired/stimulus";
import Dropzone from "dropzone";
import "dropzone/dist/dropzone.css";

export default class extends Controller {
    connect() {
        // Configure Dropzone globally (optional)
        Dropzone.autoDiscover = false; // Prevent auto-discovery of elements

        this.element.classList.add('dropzone')
        const dzMessage = document.createElement('div')
        dzMessage.classList.add('dz-message')
        dzMessage.innerHTML = '<p>Drag & drop files here or click to upload</p>'
        this.element.appendChild(dzMessage)

        document.addEventListener("DOMContentLoaded", () => {
            new Dropzone(this.element, {
                paramName: "file", // Rails expects the file field to be named 'file'
                maxFilesize: 5,    // Set the max file size (in MB)
                acceptedFiles: "image/*", // Accept only images (optional)
                headers: {
                    "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').getAttribute("content"),
                },
                success: function (file, response) {
                    console.log("File uploaded successfully:", response);
                },
                error: function (file, errorMessage) {
                    console.error("File upload failed:", errorMessage);
                },
            });
        }, { once: true });
    }
}
