#!/bin/bash
echo "=== TEST 2B: Page Templates ==="
PASS=0; FAIL=0

TEMPLATES=("ServicePage" "ServicePageSensitive" "B2BPage" "BezirkPage" "RatgeberPage" "GenericPage" "KontaktPage")
for tmpl in "${TEMPLATES[@]}"; do
  if find src/layouts -name "${tmpl}.astro" 2>/dev/null | grep -q .; then
    echo "✅ $tmpl existiert"; ((PASS++))
  else
    echo "❌ $tmpl fehlt"; ((FAIL++))
  fi
done

# Check for helper components
COMPONENTS=("Breadcrumbs" "AIReadyIntro")
for comp in "${COMPONENTS[@]}"; do
    if find src/components -name "${comp}.astro" 2>/dev/null | grep -q .; then
    echo "✅ Component $comp existiert"; ((PASS++))
  else
    echo "❌ Component $comp fehlt"; ((FAIL++))
  fi
done

echo "Starting build check..."
if npm run build > /dev/null 2>&1; then
  echo "✅ Build erfolgreich"; ((PASS++))
else
  echo "❌ Build fehlgeschlagen - check logs manually"; ((FAIL++))
fi

echo ""
echo "=== ERGEBNIS: $PASS bestanden, $FAIL fehlgeschlagen ==="
