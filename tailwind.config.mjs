/** @type {import('tailwindcss').Config} */
export default {
    content: ['./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}'],
    theme: {
        extend: {
            fontFamily: {
                sans: ['Inter', 'system-ui', '-apple-system', 'Segoe UI', 'Roboto', 'Helvetica Neue', 'Arial', 'sans-serif'],
            },
            colors: {
                primary: '#1A1A1A',
                accent: '#3B82F6',
                bgAlt: '#F8F9FA',
                textPrimary: '#1A1A1A',
                textSecondary: '#6B7280',
                border: '#E5E7EB',
                success: '#059669',
            },
        },
    },
    plugins: [],
}
