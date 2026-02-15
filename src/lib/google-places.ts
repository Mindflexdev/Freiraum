// src/lib/google-places.ts
// Google Places API (New) — Reviews fetchen für Freiraum-Auflösungen

export interface GoogleReview {
  authorName: string;
  rating: number;
  text: string;
  relativeTimeDescription: string;
  profilePhotoUrl?: string;
}

export interface PlaceReviewsData {
  placeId: string;
  rating: number;
  totalReviews: number;
  reviews: GoogleReview[];
  googleMapsUrl: string;
  fetchedAt: string;
}

/**
 * Fetcht Reviews von der Google Places API (New).
 * Wird nur vom Build-Skript aufgerufen, NICHT zur Runtime.
 */
export async function fetchGoogleReviews(
  apiKey: string,
  placeId: string,
): Promise<PlaceReviewsData> {
  // Places API (New) — Place Details mit Reviews
  const url = `https://places.googleapis.com/v1/places/${placeId}?fields=rating,userRatingCount,reviews,googleMapsUri&languageCode=de`;

  const response = await fetch(url, {
    headers: {
      'X-Goog-Api-Key': apiKey,
      'Content-Type': 'application/json',
    },
  });

  if (!response.ok) {
    const errorBody = await response.text();
    throw new Error(
      `Google Places API error (${response.status}): ${errorBody}`,
    );
  }

  const data = await response.json();

  const reviews: GoogleReview[] = (data.reviews || [])
    .slice(0, 5)
    .map((review: any) => ({
      authorName: review.authorAttribution?.displayName || 'Anonym',
      rating: review.rating || 5,
      text: review.text?.text || '',
      relativeTimeDescription: review.relativePublishTimeDescription || '',
      profilePhotoUrl: review.authorAttribution?.photoUri || undefined,
    }));

  return {
    placeId,
    rating: data.rating || 0,
    totalReviews: data.userRatingCount || 0,
    reviews,
    googleMapsUrl: data.googleMapsUri || `https://www.google.com/maps/place/?q=place_id:${placeId}`,
    fetchedAt: new Date().toISOString(),
  };
}
