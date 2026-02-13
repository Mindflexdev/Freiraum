// ================================================================
// FREIRAUM-AUFLÖSUNGEN — Tailwind v3 Fallback Config
// NUR verwenden wenn dein Projekt noch Tailwind v3 nutzt!
// Bei Tailwind v4 wird diese Datei NICHT gebraucht —
// alles ist in global.css via @theme definiert.
// ================================================================

/** @type {import('tailwindcss').Config} */
export default {
  content: ['./src/**/*.{astro,html,js,jsx,md,mdx,ts,tsx}'],
  theme: {
    extend: {

      colors: {
        bg:             { DEFAULT: '#F5F6F8', alt: '#EDF0F4', warm: '#F8F7F4' },
        ink:            { DEFAULT: '#1C2331', body: '#556070', light: '#5F6B78', faint: '#B0B8C4' },
        accent:         { DEFAULT: '#2D5A8C', hover: '#234A74', light: '#E8F0FA', soft: '#D4E4F4', dark: '#1B3F66' },
        gold:           { DEFAULT: '#C89632', hover: '#A87D28', dark: '#8A6B1E', light: '#FBF5E6', soft: '#F3E8C8' },
        card:           '#FFFFFF',
        border:         { DEFAULT: '#E0E3E8', light: '#EDF0F4', strong: '#C8CDD4' },
        success:        { DEFAULT: '#10B981', light: '#D1FAE5', dark: '#065F46' },
        error:          '#EF4444',
      },

      fontFamily: {
        sans: ['Plus Jakarta Sans', 'system-ui', '-apple-system', 'BlinkMacSystemFont', 'Segoe UI', 'sans-serif'],
      },

      fontSize: {
        'h1':       ['clamp(2rem, 1.5rem + 2.5vw, 2.75rem)',       { lineHeight: '1.08', letterSpacing: '-0.035em', fontWeight: '800' }],
        'h2':       ['clamp(1.5rem, 1.2rem + 1.5vw, 2rem)',         { lineHeight: '1.15', letterSpacing: '-0.025em', fontWeight: '700' }],
        'h3':       ['clamp(1.125rem, 1rem + 0.75vw, 1.375rem)',    { lineHeight: '1.3',  letterSpacing: '-0.015em', fontWeight: '600' }],
        'body':     ['clamp(0.9375rem, 0.9rem + 0.2vw, 1.0625rem)', { lineHeight: '1.75', letterSpacing: '0.005em',  fontWeight: '400' }],
        'small':    ['0.8125rem',                                     { lineHeight: '1.5',  letterSpacing: '0.01em',   fontWeight: '500' }],
        'overline': ['0.6875rem',                                     { lineHeight: '1.4',  letterSpacing: '0.08em',   fontWeight: '600' }],
      },

      borderRadius: {
        'card':     '1rem',
        'card-b2b': '0.5rem',
        'btn':      '0.625rem',
        'badge':    '6.25rem',
        'tag':      '0.25rem',
      },

      boxShadow: {
        'card':       '0 1px 3px rgba(28, 35, 49, 0.04)',
        'card-hover': '0 8px 24px rgba(28, 35, 49, 0.07)',
        'btn':        '0 4px 12px rgba(45, 90, 140, 0.15)',
        'btn-gold':   '0 4px 12px rgba(200, 150, 50, 0.15)',
        'nav':        '0 1px 2px rgba(28, 35, 49, 0.06)',
        'modal':      '0 20px 60px rgba(28, 35, 49, 0.12)',
      },

      maxWidth: {
        'content': '75rem',
        'prose':   '38rem',
      },

      transitionTimingFunction: {
        'smooth': 'cubic-bezier(0.4, 0, 0.2, 1)',
      },

      keyframes: {
        'fade-up': {
          '0%':   { opacity: '0', transform: 'translateY(16px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
      },
      animation: {
        'fade-up': 'fade-up 0.5s ease forwards',
      },
    },
  },
  plugins: [],
};
