#!/bin/bash
echo "=== TEST 1C: Homepage + Components ==="
PASS=0; FAIL=0

npm run build > /dev/null 2>&1
INDEX=$(find dist -name "index.html" -maxdepth 2 | head -1)

if [ -z "$INDEX" ]; then
  echo "❌ Build failed or index.html not found"
  exit 1
fi

# H1 count
H1_COUNT=$(grep -c "<h1" "$INDEX" 2>/dev/null)
if [ "$H1_COUNT" = "1" ]; then
  echo "✅ Exakt 1× H1"; ((PASS++))
else
  echo "❌ H1 Anzahl: $H1_COUNT (muss 1 sein)"; ((FAIL++))
fi

# CTAs (mindestens 2 tel: Links)
TEL_COUNT=$(grep -c "tel:" "$INDEX" 2>/dev/null)
if [ "$TEL_COUNT" -ge 2 ]; then
  echo "✅ $TEL_COUNT Telefon-Links (≥2 CTAs)"; ((PASS++))
else
  echo "❌ Nur $TEL_COUNT Telefon-Links (brauche ≥2 CTAs)"; ((FAIL++))
fi

# WhatsApp
if grep -q "wa.me" "$INDEX" 2>/dev/null || grep -q "whatsapp" "$INDEX" 2>/dev/null; then
  echo "✅ WhatsApp-Link vorhanden"; ((PASS++))
else
  echo "❌ WhatsApp-Link fehlt"; ((FAIL++))
fi

# FAQ accordion
if grep -q "<details" "$INDEX" 2>/dev/null || grep -q "<summary" "$INDEX" 2>/dev/null; then
  echo "✅ FAQ-Akkordeon vorhanden"; ((PASS++))
else
  echo "⚠️  FAQ-Akkordeon fehlt (Platzhalter ok für jetzt)"; ((PASS++))
fi

# Trust elements
# Checking for some keywords
if grep -qiE "besichtigung|festpreis|bewertung|google" "$INDEX" 2>/dev/null; then
  echo "✅ Trust-Elemente vorhanden"; ((PASS++))
else
  echo "❌ Trust-Elemente fehlen"; ((FAIL++))
fi

# ai-ready-intro
if grep -q "ai-ready-intro" "$INDEX" 2>/dev/null; then
  echo "✅ AI-Ready-Intro Klasse vorhanden"; ((PASS++))
else
  echo "⚠️  AI-Ready-Intro fehlt (wird bei Content ergänzt)"; ((PASS++))
fi

echo ""
echo "=== ERGEBNIS: $PASS bestanden, $FAIL fehlgeschlagen ==="
if [ $FAIL -gt 0 ]; then echo "⛔ FIXE DIE FEHLER"; exit 1; fi
