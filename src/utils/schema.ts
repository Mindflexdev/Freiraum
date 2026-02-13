// src/utils/schema.ts
// Schema.org JSON-LD utilities for Freiraum-Auflösungen GmbH

const SITE_URL = 'https://freiraum-aufloesung.de';
const BUSINESS_ID = `${SITE_URL}/#business`;

interface LocalBusinessOverrides {
  areaServed?: string | string[];
  additionalType?: string;
}

interface BreadcrumbItem {
  name: string;
  url: string;
}

interface FAQItem {
  question: string;
  answer: string;
}

/**
 * LocalBusiness schema — auf jeder Seite mit Geschäftsbezug
 * KEIN AggregateRating (verboten laut Briefing)
 */
export function buildLocalBusinessSchema(overrides?: LocalBusinessOverrides) {
  const areaServed = overrides?.areaServed || 'Berlin';
  const areaServedSchema = Array.isArray(areaServed)
    ? areaServed.map((name) => ({ '@type': 'City', name }))
    : { '@type': 'City', name: areaServed };

  return {
    '@context': 'https://schema.org',
    '@type': 'LocalBusiness',
    '@id': BUSINESS_ID,
    name: 'Freiraum-Auflösungen GmbH',
    url: SITE_URL,
    telephone: '+4930585816730',
    address: {
      '@type': 'PostalAddress',
      addressLocality: 'Berlin',
      addressRegion: 'Berlin',
      addressCountry: 'DE',
    },
    geo: {
      '@type': 'GeoCoordinates',
      latitude: '52.520008',
      longitude: '13.404954',
    },
    areaServed: areaServedSchema,
    ...(overrides?.additionalType && { additionalType: overrides.additionalType }),
  };
}

/**
 * BreadcrumbList schema
 */
export function buildBreadcrumbSchema(items: BreadcrumbItem[]) {
  return {
    '@context': 'https://schema.org',
    '@type': 'BreadcrumbList',
    itemListElement: items.map((item, index) => ({
      '@type': 'ListItem',
      position: index + 1,
      name: item.name,
      item: `${SITE_URL}${item.url}`,
    })),
  };
}

/**
 * Service schema — für Service- und Gewerbe-Seiten
 * areaServed kann optional überschrieben werden (z.B. für Brandenburg-Seiten)
 */
export function buildServiceSchema(name: string, description: string, areaServed?: string | string[]) {
  const area = areaServed || 'Berlin';
  const areaServedSchema = Array.isArray(area)
    ? area.map((cityName) => ({ '@type': 'City', name: cityName }))
    : { '@type': 'City', name: area };

  return {
    '@context': 'https://schema.org',
    '@type': 'Service',
    name,
    description,
    provider: {
      '@type': 'LocalBusiness',
      '@id': BUSINESS_ID,
    },
    areaServed: areaServedSchema,
  };
}

/**
 * Article schema — für Ratgeber-Seiten
 */
export function buildArticleSchema(title: string, description: string, datePublished: string) {
  return {
    '@context': 'https://schema.org',
    '@type': 'Article',
    headline: title,
    description,
    datePublished,
    author: {
      '@type': 'Organization',
      name: 'Freiraum-Auflösungen GmbH',
      url: SITE_URL,
    },
    publisher: {
      '@type': 'Organization',
      name: 'Freiraum-Auflösungen GmbH',
      url: SITE_URL,
    },
  };
}

/**
 * FAQPage schema — nur auf Seiten mit FAQPage: JA
 */
export function buildFAQSchema(items: FAQItem[]) {
  return {
    '@context': 'https://schema.org',
    '@type': 'FAQPage',
    mainEntity: items.map((item) => ({
      '@type': 'Question',
      name: item.question,
      acceptedAnswer: {
        '@type': 'Answer',
        text: item.answer,
      },
    })),
  };
}

/**
 * ContactPoint schema — für die Kontakt-Seite
 */
export function buildContactPointSchema() {
  return {
    '@context': 'https://schema.org',
    '@type': 'ContactPoint',
    telephone: '+4930585816730',
    contactType: 'customer service',
    availableLanguage: 'German',
    areaServed: {
      '@type': 'City',
      name: 'Berlin',
    },
  };
}

/**
 * AboutPage schema — für die Über-uns-Seite
 * Briefing §5.1: "Über uns: BreadcrumbList + AboutPage + Person"
 */
export function buildAboutPageSchema() {
  return {
    '@context': 'https://schema.org',
    '@type': 'AboutPage',
    name: 'Über uns – Freiraum-Auflösungen GmbH',
    description: 'Lernen Sie das Team von Freiraum-Auflösungen kennen.',
    url: `${SITE_URL}/ueber-uns/`,
    mainEntity: {
      '@type': 'Organization',
      '@id': BUSINESS_ID,
      name: 'Freiraum-Auflösungen GmbH',
      url: SITE_URL,
      telephone: '+4930585816730',
    },
  };
}

/**
 * Kombiniert mehrere Schema-Objekte in ein @graph-Array
 * Google empfiehlt ein einziges <script type="application/ld+json"> pro Seite
 */
export function combineSchemas(...schemas: object[]) {
  return {
    '@context': 'https://schema.org',
    '@graph': schemas.map(({ '@context': _, ...rest }) => rest),
  };
}
