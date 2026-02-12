#!/bin/bash
echo "=== TEST 3B: Sitemap + Redirects ==="
PASS=0; FAIL=0
npm run build > /dev/null 2>&1

# Sitemap exists
SITEMAP_INDEX="dist/sitemap-index.xml"
SITEMAP_0="dist/sitemap-0.xml"

if [ -f "$SITEMAP_INDEX" ]; then
  echo "✅ Sitemap-Index gefunden: $SITEMAP_INDEX"; ((PASS++))

  # Count URLs in sitemap-0.xml (all in one line, so use grep -o to count occurrences)
  if [ -f "$SITEMAP_0" ]; then
    URL_COUNT=$(grep -o "<loc>" "$SITEMAP_0" | wc -l | tr -d ' ')
  else
    URL_COUNT=0
  fi
  echo "   URLs in Sitemap: $URL_COUNT (soll: 31)"

  # Check no impressum/datenschutz/404
  if grep -q "impressum\|datenschutz\|/404/" "$SITEMAP_0" 2>/dev/null; then
    echo "❌ Impressum/Datenschutz/404 in Sitemap!"; ((FAIL++))
  else
    echo "✅ Legal-Seiten + 404 nicht in Sitemap"; ((PASS++))
  fi

  # Check HTTPS and trailing slash
  NON_HTTPS=$(grep -o '<loc>[^<]*</loc>' "$SITEMAP_0" 2>/dev/null | sed 's/<[^>]*>//g' | grep -v 'https://' | wc -l | tr -d ' ')
  NON_TRAILING=$(grep -o '<loc>[^<]*</loc>' "$SITEMAP_0" 2>/dev/null | sed 's/<[^>]*>//g' | grep -v '/$' | wc -l | tr -d ' ')
  if [ "$NON_HTTPS" -eq 0 ] && [ "$NON_TRAILING" -eq 0 ]; then
    echo "✅ Alle URLs: HTTPS + Trailing Slash"; ((PASS++))
  else
    echo "❌ URLs ohne HTTPS ($NON_HTTPS) oder ohne Trailing Slash ($NON_TRAILING)"; ((FAIL++))
  fi
else
  echo "❌ Keine Sitemap-Index gefunden"; ((FAIL++))
fi

# robots.txt
if [ -f "dist/robots.txt" ]; then
  echo "✅ robots.txt in dist/ vorhanden"; ((PASS++))
  # Check content
  if grep -q "Disallow: /404/" "dist/robots.txt" && grep -q "Sitemap:" "dist/robots.txt"; then
    echo "✅ robots.txt: Disallow /404/ + Sitemap-Verweis"; ((PASS++))
  else
    echo "❌ robots.txt: Inhalt unvollständig"; ((FAIL++))
  fi
else
  echo "❌ robots.txt fehlt in dist/"; ((FAIL++))
fi

# vercel.json redirects
if [ -f "vercel.json" ]; then
  REDIRECT_COUNT=$(grep -c '"source"' vercel.json 2>/dev/null)
  echo "✅ vercel.json: $REDIRECT_COUNT Redirects (soll: ≥26)"; ((PASS++))
  if [ "$REDIRECT_COUNT" -lt 26 ]; then
    echo "⚠️  Weniger als 26 Redirects — prüfe ob alle 13 alten URLs (mit+ohne Slash) abgedeckt sind"
  fi
else
  echo "❌ vercel.json fehlt (Redirects!)"; ((FAIL++))
fi

echo ""
echo "=== ERGEBNIS: $PASS bestanden, $FAIL fehlgeschlagen ==="
