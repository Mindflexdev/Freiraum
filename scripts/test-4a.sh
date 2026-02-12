#!/bin/bash
echo "=== TEST 4A: Performance ==="
PASS=0; FAIL=0
npm run build > /dev/null 2>&1
# No external fonts
if grep -rq "fonts.googleapis.com\|fonts.gstatic.com" dist/ 2>/dev/null; then
  echo "❌ EXTERNE FONTS — DSGVO-Problem + Performance!"; ((FAIL++))
else
  echo "✅ Keine externen Fonts"; ((PASS++))
fi
# CSS size
CSS_SIZE=$(find dist -name "*.css" -exec wc -c {} + 2>/dev/null | tail -1 | awk '{print $1}')
if [ -n "$CSS_SIZE" ] && [ "$CSS_SIZE" -lt 100000 ]; then
  echo "✅ CSS Gesamtgröße: ${CSS_SIZE} Bytes"; ((PASS++))
else
  echo "⚠️  CSS Größe: ${CSS_SIZE:-unbekannt} Bytes"; ((PASS++))
fi
# JS size (excluding JSON-LD)
JS_SIZE=$(find dist -name "*.js" ! -name "*.json" -exec wc -c {} + 2>/dev/null | tail -1 | awk '{print $1}')
echo "   JS Gesamtgröße: ${JS_SIZE:-0} Bytes"
# Images have width/height
IMG_NO_WIDTH=$(grep -rn "<img" dist/ 2>/dev/null | grep -v "width=" | grep -v "svg" | wc -l)
if [ "$IMG_NO_WIDTH" -eq 0 ]; then
  echo "✅ Alle Bilder haben width/height"; ((PASS++))
else
  echo "⚠️  $IMG_NO_WIDTH Bilder ohne width-Attribut (CLS-Risiko)"; ((PASS++))
fi
# Total build size (macOS-kompatibel: du -sk statt du -sb)
TOTAL_KB=$(du -sk dist/ 2>/dev/null | awk '{print $1}')
echo "   Build-Gesamtgröße: ${TOTAL_KB} KB"
if [ "$TOTAL_KB" -lt 2000 ]; then
  echo "✅ Build unter 2 MB"; ((PASS++))
else
  echo "⚠️  Build über 2 MB — prüfen"; ((PASS++))
fi
echo ""
echo "=== ERGEBNIS: $PASS bestanden, $FAIL fehlgeschlagen ==="
echo "→ MANUELL: pagespeed.web.dev mit Vercel-URL testen (Ziel Mobile ≥ 85)"
