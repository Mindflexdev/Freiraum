#!/usr/bin/env npx tsx
// scripts/fetch-reviews.ts
// Fetcht Google Reviews und speichert sie in src/data/reviews.json
// Nutzung: npx tsx scripts/fetch-reviews.ts
// Oder:   npm run fetch-reviews (nach package.json-Update)

import { writeFileSync, readFileSync, existsSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const REVIEWS_PATH = resolve(__dirname, '../src/data/reviews.json');

// .env manuell lesen (keine externe Dependency)
function loadEnv(): Record<string, string> {
  const envPath = resolve(__dirname, '../.env');
  if (!existsSync(envPath)) {
    return {};
  }
  const content = readFileSync(envPath, 'utf-8');
  const env: Record<string, string> = {};
  for (const line of content.split('\n')) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith('#')) continue;
    const eqIndex = trimmed.indexOf('=');
    if (eqIndex === -1) continue;
    const key = trimmed.slice(0, eqIndex).trim();
    const value = trimmed.slice(eqIndex + 1).trim();
    env[key] = value;
  }
  return env;
}

async function main() {
  const env = loadEnv();
  const apiKey = process.env.GOOGLE_PLACES_API_KEY || env.GOOGLE_PLACES_API_KEY;
  const placeId = process.env.GOOGLE_PLACE_ID || env.GOOGLE_PLACE_ID;

  if (!apiKey || !placeId) {
    console.error('Fehler: GOOGLE_PLACES_API_KEY und GOOGLE_PLACE_ID müssen gesetzt sein.');
    console.error('Erstelle eine .env Datei basierend auf .env.example');
    process.exit(1);
  }

  // Prüfe ob Reviews noch aktuell (< 24h alt)
  if (existsSync(REVIEWS_PATH)) {
    try {
      const existing = JSON.parse(readFileSync(REVIEWS_PATH, 'utf-8'));
      const fetchedAt = new Date(existing.fetchedAt).getTime();
      const ageHours = (Date.now() - fetchedAt) / (1000 * 60 * 60);

      if (ageHours < 24 && existing.reviews?.length > 0) {
        console.log(`Reviews sind ${Math.round(ageHours)}h alt (< 24h). Überspringe API-Call.`);
        console.log(`Zum Erzwingen: lösche src/data/reviews.json und starte erneut.`);
        return;
      }
    } catch {
      // JSON ungültig, neu fetchen
    }
  }

  console.log(`Fetche Reviews für Place ID: ${placeId}...`);

  // Google Places API (New) aufrufen
  const url = `https://places.googleapis.com/v1/places/${placeId}?fields=rating,userRatingCount,reviews,googleMapsUri&languageCode=de`;

  const response = await fetch(url, {
    headers: {
      'X-Goog-Api-Key': apiKey,
      'Content-Type': 'application/json',
    },
  });

  if (!response.ok) {
    const errorBody = await response.text();
    console.error(`API Fehler (${response.status}): ${errorBody}`);
    process.exit(1);
  }

  const data = await response.json();

  const reviews = (data.reviews || []).slice(0, 5).map((review: any) => ({
    authorName: review.authorAttribution?.displayName || 'Anonym',
    rating: review.rating || 5,
    text: review.text?.text || '',
    relativeTimeDescription: review.relativePublishTimeDescription || '',
    profilePhotoUrl: review.authorAttribution?.photoUri || undefined,
  }));

  const reviewsData = {
    placeId,
    rating: data.rating || 0,
    totalReviews: data.userRatingCount || 0,
    reviews,
    googleMapsUrl:
      data.googleMapsUri ||
      `https://www.google.com/maps/place/?q=place_id:${placeId}`,
    fetchedAt: new Date().toISOString(),
  };

  writeFileSync(REVIEWS_PATH, JSON.stringify(reviewsData, null, 2) + '\n');

  console.log(`Reviews gespeichert in ${REVIEWS_PATH}`);
  console.log(`Rating: ${reviewsData.rating}/5 (${reviewsData.totalReviews} Bewertungen)`);
  console.log(`${reviews.length} Reviews geladen.`);
}

main().catch((err) => {
  console.error('Unerwarteter Fehler:', err);
  process.exit(1);
});
