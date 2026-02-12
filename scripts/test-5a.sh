#!/bin/bash
echo "=== TEST 5A: Tracking + DSGVO ==="
PASS=0; FAIL=0

npm run build > /dev/null 2>&1

HOME=$(find dist -maxdepth 1 -name "index.html" | head -1)

# Cookie banner component
if find src -name "*ookie*" -o -name "*onsent*" 2>/dev/null | grep -q .; then
  echo "✅ Cookie-Banner Component vorhanden"; ((PASS++))
else
  echo "❌ Cookie-Banner fehlt"; ((FAIL++))
fi

# Data Layer
if grep -q "dataLayer" "$HOME" 2>/dev/null; then
  echo "✅ Data Layer vorhanden"; ((PASS++))
else
  echo "❌ Data Layer fehlt"; ((FAIL++))
fi

# GTM NOT loaded without consent (no <script src="...gtm.js"> tag)
if grep -qP '<script[^>]+src=["\x27][^"]*googletagmanager\.com/gtm\.js' "$HOME" 2>/dev/null; then
  echo "❌ GTM DIREKT IM HTML — muss per Consent geladen werden!"; ((FAIL++))
else
  echo "✅ GTM nicht direkt geladen (gut — wird per Consent gesteuert)"; ((PASS++))
fi

# Verify GTM is consent-gated (loaded inside JS function)
if grep -q "cookie_consent" "$HOME" 2>/dev/null; then
  echo "✅ Cookie-Consent Prüfung im Code vorhanden"; ((PASS++))
else
  echo "❌ Keine Cookie-Consent Prüfung gefunden"; ((FAIL++))
fi

# No external requests without consent check
if grep -rq "fonts.googleapis\|ajax.googleapis\|cdnjs.cloudflare" dist/ 2>/dev/null; then
  echo "❌ Externe Requests ohne Consent!"; ((FAIL++))
else
  echo "✅ Keine unkontrollierten externen Requests"; ((PASS++))
fi

echo ""
echo "=== ERGEBNIS: $PASS bestanden, $FAIL fehlgeschlagen ==="
echo "→ MANUELL: Vercel öffnen, Cookie-Banner testen (Akzeptieren + Ablehnen)"
