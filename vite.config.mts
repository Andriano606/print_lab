import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import sass from 'sass'

export default defineConfig({
    plugins: [
      RubyPlugin(),
    ],
    css: {
        preprocessorOptions: {
            sass: {
                additionalData: `@import "./app/javascript/entrypoints/application.scss";` // Auto-importing your main Sass file
            }
        }
    },
    server: {
        watch: {
            usePolling: true, // Enable HMR for CSS updates
        }
    },
})
