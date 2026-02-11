#!/bin/bash
echo "=== TEST 1A: Projekt-Config ==="
PASS=0; FAIL=0

# Build test
if npm run build > /dev/null 2>&1; then
  echo "✅ Build erfolgreich"; ((PASS++))
else
  echo "❌ Build fehlgeschlagen"; ((FAIL++))
fi

# Check astro.config
if grep -q "trailingslash.*always" astro.config.mjs 2>/dev/null || grep -q "trailingSlash: 'always'" astro.config.mjs 2>/dev/null; then
  echo "✅ trailingSlash: always"; ((PASS++))
else
  echo "❌ trailingSlash fehlt oder falsch"; ((FAIL++))
fi

if grep -q "freiraum-aufloesung.de" astro.config.mjs 2>/dev/null; then
  echo "✅ Site-URL korrekt"; ((PASS++))
else
  echo "❌ Site-URL fehlt"; ((FAIL++))
fi

# Check BaseLayout
LAYOUT=$(find src -name "BaseLayout.astro" -o -name "Layout.astro" -o -name "Base.astro" 2>/dev/null | head -1)
if [ -n "$LAYOUT" ]; then
  echo "✅ BaseLayout gefunden: $LAYOUT"; ((PASS++))
  if grep -q 'lang="de"' "$LAYOUT" 2>/dev/null; then
    echo "✅ lang=de vorhanden"; ((PASS++))
  else
    echo "❌ lang=de fehlt"; ((FAIL++))
  fi
  if grep -q "canonical" "$LAYOUT" 2>/dev/null; then
    echo "✅ Canonical-Tag vorhanden"; ((PASS++))
  else
    echo "❌ Canonical-Tag fehlt"; ((FAIL++))
  fi
  if grep -q "dataLayer" "$LAYOUT" 2>/dev/null; then
    echo "✅ Data Layer vorhanden"; ((PASS++))
  else
    echo "⚠️  Data Layer fehlt (wird in Phase 5 benötigt)"; ((PASS++))
  fi
else
  echo "❌ Kein BaseLayout gefunden"; ((FAIL++))
fi

# Check no external fonts
if grep -rq "fonts.googleapis.com" src/ 2>/dev/null; then
  echo "❌ EXTERNE FONTS GEFUNDEN — DSGVO-Problem!"; ((FAIL++))
else
  echo "✅ Keine externen Font-Requests"; ((PASS++))
fi

# Check tailwind
if [ -f "tailwind.config.mjs" ] || [ -f "tailwind.config.js" ] || [ -f "tailwind.config.ts" ]; then
  echo "✅ Tailwind-Config vorhanden"; ((PASS++))
else
  echo "❌ Tailwind-Config fehlt"; ((FAIL++))
fi

echo ""
echo "=== ERGEBNIS: $PASS bestanden, $FAIL fehlgeschlagen ==="
if [ $FAIL -gt 0 ]; then echo "⛔ FIXE DIE FEHLER BEVOR DU WEITERMACHST"; fi
