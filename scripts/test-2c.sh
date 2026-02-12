#!/bin/bash
echo "=== TEST 2C: Services + Gewerbe + B2B (16 Seiten) ==="
PASS=0; FAIL=0
npm run build > /dev/null 2>&1
URLS=(
  "index.html"
  "hausaufloesung-berlin/index.html"
  "haushaltsaufloesung-berlin/index.html"
  "entruempelung-berlin/index.html"
  "nachlassverwertung-berlin/index.html"
  "wohnungsaufloesung-todesfall/index.html"
  "seniorenumzug-wohnungsaufloesung/index.html"
  "gewerbeaufloesung-berlin/index.html"
  "bueroaufloesung-berlin/index.html"
  "praxisaufloesung-berlin/index.html"
  "restaurantaufloesung-berlin/index.html"
  "firmenaufloesung-berlin/index.html"
  "lageraufloesung-berlin/index.html"
  "fuer-insolvenzverwalter/index.html"
  "fuer-hausverwaltungen/index.html"
  "fuer-makler/index.html"
)
for url in "${URLS[@]}"; do
  if [ -f "dist/$url" ]; then
    ((PASS++))
  else
    echo "❌ FEHLT: dist/$url"; ((FAIL++))
  fi
done
echo "✅ $PASS von 16 Seiten vorhanden"
if [ $FAIL -gt 0 ]; then echo "❌ $FAIL Seiten fehlen"; fi
echo ""
echo "=== ERGEBNIS: $PASS bestanden, $FAIL fehlgeschlagen ==="
