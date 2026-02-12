#!/bin/bash
echo "=== TEST 2D: Bezirke + Rest (18 Seiten) ==="
PASS=0; FAIL=0
npm run build > /dev/null 2>&1
URLS=(
  "berlin-steglitz-zehlendorf/index.html"
  "wohnungsaufloesung-zehlendorf/index.html"
  "wohnungsaufloesung-dahlem/index.html"
  "berlin-charlottenburg-wilmersdorf/index.html"
  "wohnungsaufloesung-charlottenburg/index.html"
  "wohnungsaufloesung-grunewald/index.html"
  "wohnungsaufloesung-schmargendorf/index.html"
  "brandenburg-potsdam-umland/index.html"
  "wohnungsaufloesung-potsdam/index.html"
  "wohnungsaufloesung-kleinmachnow/index.html"
  "ratgeber/wohnungsaufloesung-durch-betreuer/index.html"
  "ratgeber/wohnungsaufloesung-kosten/index.html"
  "ueber-uns/index.html"
  "kontakt/index.html"
  "faq/index.html"
  "impressum/index.html"
  "datenschutz/index.html"
  "404.html"
)
for url in "${URLS[@]}"; do
  if [ -f "dist/$url" ]; then
    ((PASS++))
  else
    echo "❌ FEHLT: dist/$url"; ((FAIL++))
  fi
done
echo "✅ $PASS von 18 Seiten vorhanden"
if [ $FAIL -gt 0 ]; then echo "❌ $FAIL Seiten fehlen"; fi
echo ""
echo "=== ERGEBNIS: $PASS bestanden, $FAIL fehlgeschlagen ==="
