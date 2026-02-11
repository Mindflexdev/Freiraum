#!/bin/bash
echo "=== TEST 2A: Shared Components ==="
PASS=0; FAIL=0

COMPONENTS=("HeroCTA" "InlineCTA" "EndCTA" "CTASoft" "CTAB2B" "ContactFormB2C" "ContactFormB2B" "TrustBadges" "FAQAccordion")
for comp in "${COMPONENTS[@]}"; do
  if find src/components -name "${comp}.astro" 2>/dev/null | grep -q .; then
    echo "✅ $comp existiert"; ((PASS++))
  else
    echo "❌ $comp fehlt"; ((FAIL++))
  fi
done

# Check formspree action
if grep -rq "formspree.io" src/components/ 2>/dev/null; then
  echo "✅ Formspree-Action vorhanden"; ((PASS++))
else
  echo "❌ Formular-Endpoint fehlt (Formspree)"; ((FAIL++))
fi

# Check honeypot
if grep -rq "_gotcha\|honeypot\|bot-field" src/components/ 2>/dev/null; then
  echo "✅ Spam-Schutz vorhanden"; ((PASS++))
else
  echo "❌ Honeypot/Spam-Schutz fehlt"; ((FAIL++))
fi

# Build check
if npm run build > /dev/null 2>&1; then
  echo "✅ Build erfolgreich"; ((PASS++))
else
  echo "❌ Build fehlgeschlagen"; ((FAIL++))
fi

echo ""
echo "=== ERGEBNIS: $PASS bestanden, $FAIL fehlgeschlagen ==="
