// @ts-check
import { defineConfig } from 'astro/config';
import tailwind from '@astrojs/tailwind';
import sitemap from '@astrojs/sitemap';

// https://astro.build/config
export default defineConfig({
    output: 'static',
    trailingSlash: 'always',
    site: 'https://freiraum-aufloesung.de',
    integrations: [
        tailwind(),
        sitemap({
            filter: (page) =>
                page !== 'https://freiraum-aufloesung.de/impressum/' &&
                page !== 'https://freiraum-aufloesung.de/datenschutz/' &&
                page !== 'https://freiraum-aufloesung.de/404/',
        }),
    ],
});
