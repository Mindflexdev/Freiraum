// src/config/navigation.ts

export interface NavItem {
    name: string;
    href: string;
    subItems?: NavItem[];
}

export interface FooterSection {
    title: string;
    items: NavItem[];
}

export const mainNavigation: NavItem[] = [
    { name: 'Home', href: '/' },
    {
        name: 'Dienstleistungen',
        href: '#', // Placeholder for mega-menu trigger, or link to a services overview if exists
        subItems: [
            { name: 'Wohnungsauflösung', href: '/' }, // Homepage acts as main service page
            { name: 'Hausauflösung', href: '/hausaufloesung-berlin/' },
            { name: 'Haushaltsauflösung', href: '/haushaltsaufloesung-berlin/' },
            { name: 'Entrümpelung', href: '/entruempelung-berlin/' },
            { name: 'Nachlassverwertung', href: '/nachlassverwertung-berlin/' },
            { name: 'Seniorenumzug', href: '/seniorenumzug-wohnungsaufloesung/' },
            { name: 'Gewerbeauflösung', href: '/gewerbeaufloesung-berlin/' },
            { name: 'Büroauflösung', href: '/bueroaufloesung-berlin/' },
            { name: 'Praxisauflösung', href: '/praxisaufloesung-berlin/' },
            { name: 'Restaurantauflösung', href: '/restaurantaufloesung-berlin/' },
            { name: 'Firmenauflösung', href: '/firmenaufloesung-berlin/' },
            { name: 'Lagerauflösung', href: '/lageraufloesung-berlin/' },
        ],
    },
    {
        name: 'Bezirke',
        href: '#', // Identifying as a dropdown/mega-menu if needed, or link to a districts overview
        subItems: [
            { name: 'Steglitz-Zehlendorf', href: '/berlin-steglitz-zehlendorf/' },
            { name: 'Charlottenburg-Wilmersdorf', href: '/berlin-charlottenburg-wilmersdorf/' },
            { name: 'Potsdam & Umland', href: '/brandenburg-potsdam-umland/' },
        ]
    },
    { name: 'Ratgeber', href: '/ratgeber/' }, // Assuming /ratgeber/ exists as an index, otherwise list specific articles
    { name: 'Über uns', href: '/ueber-uns/' },
    { name: 'Kontakt', href: '/kontakt/' },
];

export const footerNavigation: FooterSection[] = [
    {
        title: 'Dienstleistungen',
        items: [
            { name: 'Wohnungsauflösung', href: '/' },
            { name: 'Hausauflösung', href: '/hausaufloesung-berlin/' },
            { name: 'Entrümpelung', href: '/entruempelung-berlin/' },
            { name: 'Gewerbeauflösung', href: '/gewerbeaufloesung-berlin/' },
            { name: 'Seniorenumzug', href: '/seniorenumzug-wohnungsaufloesung/' },
        ],
    },
    {
        title: 'Bezirke',
        items: [
            { name: 'Zehlendorf', href: '/wohnungsaufloesung-zehlendorf/' },
            { name: 'Steglitz', href: '/berlin-steglitz-zehlendorf/' }, // Using Hub as proxy for Steglitz coverage
            { name: 'Charlottenburg', href: '/wohnungsaufloesung-charlottenburg/' },
            { name: 'Wilmersdorf', href: '/berlin-charlottenburg-wilmersdorf/' }, // Using Hub
            { name: 'Potsdam', href: '/wohnungsaufloesung-potsdam/' },
        ],
    },
    {
        title: 'Unternehmen',
        items: [
            { name: 'Über uns', href: '/ueber-uns/' },
            { name: 'Kontakt', href: '/kontakt/' },
            { name: 'Impressum', href: '/impressum/' },
            { name: 'Datenschutz', href: '/datenschutz/' },
        ],
    },
];

export const contactData = {
    phone: '030 585 816 730',
    phoneHref: 'tel:+4930585816730',
    whatsappHref: 'https://wa.me/4930585816730',
    companyName: 'Freiraum-Auflösungen GmbH',
};
