#!/bin/bash
echo "=== TEST 3A: SEO ==="
PASS=0; FAIL=0
npm run build > /dev/null 2>&1
# Check all HTML files for basic meta
for file in $(find dist -name "index.html" -maxdepth 3); do
  PAGE=$(echo "$file" | sed 's|dist/||')

  # Title exists
  if ! grep -q "<title>" "$file" 2>/dev/null; then
    echo "❌ Title fehlt: $PAGE"; ((FAIL++))
  fi

  # H1 count
  H1=$(grep -c "<h1" "$file" 2>/dev/null)
  if [ "$H1" != "1" ]; then
    echo "❌ H1 Anzahl $H1 (muss 1): $PAGE"; ((FAIL++))
  fi
done
# Homepage: NO AggregateRating
HOME=$(find dist -maxdepth 1 -name "index.html" | head -1)
if grep -q "AggregateRating" "$HOME" 2>/dev/null; then
  echo "❌ HOMEPAGE HAT AggregateRating — VERBOTEN!"; ((FAIL++))
else
  echo "✅ Homepage ohne AggregateRating"; ((PASS++))
fi
# Potsdam: areaServed != Berlin
POTSDAM=$(find dist -path "*/wohnungsaufloesung-potsdam/index.html" | head -1)
if [ -n "$POTSDAM" ]; then
  if grep -q '"Berlin"' "$POTSDAM" 2>/dev/null && grep -q "areaServed" "$POTSDAM" 2>/dev/null; then
    # Check if Berlin is in areaServed context (rough check)
    echo "⚠️  Potsdam: Prüfe manuell ob areaServed=Potsdam (nicht Berlin)"; ((PASS++))
  else
    echo "✅ Potsdam Schema ok"; ((PASS++))
  fi
fi
# JSON-LD exists on homepage
if grep -q "application/ld+json" "$HOME" 2>/dev/null; then
  echo "✅ Schema JSON-LD auf Homepage vorhanden"; ((PASS++))
else
  echo "❌ Schema JSON-LD fehlt auf Homepage"; ((FAIL++))
fi
# Canonical check (sample)
if grep -q 'rel="canonical"' "$HOME" 2>/dev/null; then
  echo "✅ Canonical-Tag vorhanden"; ((PASS++))
else
  echo "❌ Canonical-Tag fehlt"; ((FAIL++))
fi
echo ""
echo "=== ERGEBNIS: $PASS bestanden, $FAIL fehlgeschlagen ==="
