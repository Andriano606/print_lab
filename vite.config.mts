import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import tailwindcss from 'tailwindcss'
import autoprefixer from 'autoprefixer'

export default defineConfig({
    plugins: [
      RubyPlugin(),
    ],
    css: {
        preprocessorOptions: {
            sass: {
                additionalData: `@use "./app/javascript/entrypoints/application.scss";` // Auto-importing your main Sass file
            }
        },
        postcss: {
            plugins: [
                tailwindcss,
                autoprefixer,
            ],
        },
    },
    server: {
        watch: {
            usePolling: true,
        }
    },
})
