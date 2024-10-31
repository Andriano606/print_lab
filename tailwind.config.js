/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './app/helpers/**/*.rb',
    './app/javascript/**/*.{js,jsx,ts,tsx,vue}',
    './app/views/**/*.{html,erb,slim}',
    './app/assets/stylesheets/**/*.{css,scss}',
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
