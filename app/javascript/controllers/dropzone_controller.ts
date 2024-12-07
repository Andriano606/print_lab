import { Controller } from "@hotwired/stimulus";
import Dropzone from "dropzone";
import "dropzone/dist/dropzone.css";
import Rails from "@rails/ujs"

export default class extends Controller {
    connect() {
        // Configure Dropzone globally (optional)
        Dropzone.autoDiscover = false; // Prevent auto-discovery of elements

        document.addEventListener("DOMContentLoaded", () => {
            let element = this.element as HTMLFormElement

            let uploadMultiple = true
            if (element.dataset.uploadMultiple !== undefined) {
                uploadMultiple = element.dataset.uploadMultiple === 'true'
            }
            let parallelUploads = uploadMultiple ? 50 : 1
            let method = 'post'
            if (element.getAttribute('method') !== undefined) {
                method = element.getAttribute('method')
            }
            new Dropzone(element, {
                timeout: 180000,
                uploadMultiple: uploadMultiple,
                method: method.toLowerCase(),
                parallelUploads: parallelUploads,
                // The request Dropzone sends to the server is interpreted as a JavaScript
                // request but is not evaluated by Dropzone. We need to evaluate it
                // manually to make redirects, which are implemented via Turbo, work.
                //
                // The issue was also reported here:
                // https://github.com/enyo/dropzone/issues/1595
                init: function () {
                    this.on('success', (file, response) => {
                        eval(response)
                    })
                },

                dictDefaultMessage: element.dataset.dictDefaultMessage,
                paramName: element.dataset.paramName || 'file',

                // We need to include the CSRF token in order to avoid triggering a CSRF
                // token error on the server.
                headers: {
                    'X-CSRF-Token': Rails.csrfToken(),
                    Accept: 'application/javascript',
                },
            })
        }, { once: true });
    }
}
