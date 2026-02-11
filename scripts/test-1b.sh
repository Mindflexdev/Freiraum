#!/bin/bash
echo "=== TEST 1B: Header + Footer ==="
PASS=0; FAIL=0

# Clean dist to ensure fresh build
rm -rf dist

npm run build > /dev/null 2>&1

# Find index.html in build output
INDEX=$(find dist -name "index.html" -maxdepth 2 | head -1)
if [ -z "$INDEX" ]; then
  echo "❌ Kein index.html im Build gefunden"
  exit 1
fi

# Skip-to-content
if grep -q "Zum Inhalt" "$INDEX" 2>/dev/null && grep -q "#main" "$INDEX" 2>/dev/null; then
  echo "✅ Skip-to-Content vorhanden"; ((PASS++))
else
  echo "❌ Skip-to-Content fehlt"; ((FAIL++))
fi

# Telefonnummer (checking both formatted and clean versions)
if grep -q "030 585 816 730" "$INDEX" 2>/dev/null || grep -q "4930585816730" "$INDEX" 2>/dev/null; then
  echo "✅ Telefonnummer vorhanden"; ((PASS++))
else
  echo "❌ Telefonnummer fehlt"; ((FAIL++))
fi

# NAP im Footer
if grep -q "Freiraum" "$INDEX" 2>/dev/null; then
  echo "✅ Firmenname vorhanden"; ((PASS++))
else
  echo "❌ Firmenname fehlt"; ((FAIL++))
fi

# aria-label auf nav
if grep -q 'aria-label' "$INDEX" 2>/dev/null; then
  echo "✅ ARIA-Labels vorhanden"; ((PASS++))
else
  echo "❌ ARIA-Labels fehlen"; ((FAIL++))
fi

# Impressum/Datenschutz Links
if grep -q "/impressum/" "$INDEX" 2>/dev/null; then
  echo "✅ Impressum-Link vorhanden"; ((PASS++))
else
  echo "❌ Impressum-Link fehlt"; ((FAIL++))
fi

if grep -q "/datenschutz/" "$INDEX" 2>/dev/null; then
  echo "✅ Datenschutz-Link vorhanden"; ((PASS++))
else
  echo "❌ Datenschutz-Link fehlt"; ((FAIL++))
fi

# Mega Menu check (simple presence check for "Dienstleistungen")
if grep -q "Dienstleistungen" "$INDEX" 2>/dev/null; then
  echo "✅ Mega-Menu Navigationspunkt vorhanden"; ((PASS++))
else
  echo "❌ Mega-Menu Navigationspunkt fehlt"; ((FAIL++))
fi

echo ""
echo "=== ERGEBNIS: $PASS bestanden, $FAIL fehlgeschlagen ==="
if [ $FAIL -gt 0 ]; then echo "⛔ FIXE DIE FEHLER"; exit 1; fi
exit 0
