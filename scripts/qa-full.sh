#!/usr/bin/env bash
# =============================================================================
# QA Full Test Suite — Freiraum-Auflösungen GmbH Website
# Runs all automated quality checks against the built dist/ directory.
# Compatible with bash 3.2+ (macOS) and bash 4+ (Linux/CI).
# Exit 1 on any failure.
# =============================================================================

set -uo pipefail

DIST="dist"
ERRORS=0
PASS="✅"
FAIL="❌"

# ---------------------------------------------------------------------------
# Helper: print result and track errors
# ---------------------------------------------------------------------------
check() {
  local status="$1"
  local label="$2"
  local detail="${3:-}"
  if [ "$status" = "pass" ]; then
    echo "$PASS $label"
  else
    echo "$FAIL $label"
    [ -n "$detail" ] && echo "   $detail"
    ERRORS=$((ERRORS + 1))
  fi
}

# ---------------------------------------------------------------------------
# Collect all HTML pages into a temp file (avoids mapfile)
# ---------------------------------------------------------------------------
ALL_HTML_FILE=$(mktemp)
find "$DIST" -name "*.html" | sort > "$ALL_HTML_FILE"
HTML_COUNT=$(wc -l < "$ALL_HTML_FILE" | tr -d ' ')
trap 'rm -f "$ALL_HTML_FILE"' EXIT

# Expected pages (34 total: 33 index.html + 1 404.html)
EXPECTED_PAGES="dist/index.html
dist/404.html
dist/berlin-charlottenburg-wilmersdorf/index.html
dist/berlin-steglitz-zehlendorf/index.html
dist/brandenburg-potsdam-umland/index.html
dist/bueroaufloesung-berlin/index.html
dist/datenschutz/index.html
dist/entruempelung-berlin/index.html
dist/faq/index.html
dist/firmenaufloesung-berlin/index.html
dist/fuer-hausverwaltungen/index.html
dist/fuer-insolvenzverwalter/index.html
dist/fuer-makler/index.html
dist/gewerbeaufloesung-berlin/index.html
dist/hausaufloesung-berlin/index.html
dist/haushaltsaufloesung-berlin/index.html
dist/impressum/index.html
dist/kontakt/index.html
dist/lageraufloesung-berlin/index.html
dist/nachlassverwertung-berlin/index.html
dist/praxisaufloesung-berlin/index.html
dist/ratgeber/wohnungsaufloesung-durch-betreuer/index.html
dist/ratgeber/wohnungsaufloesung-kosten/index.html
dist/restaurantaufloesung-berlin/index.html
dist/seniorenumzug-wohnungsaufloesung/index.html
dist/ueber-uns/index.html
dist/wohnungsaufloesung-charlottenburg/index.html
dist/wohnungsaufloesung-dahlem/index.html
dist/wohnungsaufloesung-grunewald/index.html
dist/wohnungsaufloesung-kleinmachnow/index.html
dist/wohnungsaufloesung-potsdam/index.html
dist/wohnungsaufloesung-schmargendorf/index.html
dist/wohnungsaufloesung-todesfall/index.html
dist/wohnungsaufloesung-zehlendorf/index.html"

echo "========================================"
echo " QA Full Test Suite"
echo " $(date)"
echo "========================================"
echo ""

# ==========================================================================
# (a) Alle 34 Seiten existieren in dist/
# ==========================================================================
echo "--- (a) Alle 34 Seiten existieren ---"
MISSING=""
while IFS= read -r page; do
  if [ ! -f "$page" ]; then
    MISSING="$MISSING $page"
  fi
done <<< "$EXPECTED_PAGES"

if [ -z "$MISSING" ] && [ "$HTML_COUNT" -eq 34 ]; then
  check pass "(a) Alle 34 Seiten existieren in dist/"
else
  detail=""
  [ -n "$MISSING" ] && detail="Fehlend:$MISSING"
  [ "$HTML_COUNT" -ne 34 ] && detail="$detail | Gefunden: $HTML_COUNT statt 34"
  check fail "(a) Alle 34 Seiten existieren in dist/" "$detail"
fi

# ==========================================================================
# (b) Jede Seite hat Title <= 58 Zeichen
# ==========================================================================
echo "--- (b) Title <= 58 Zeichen ---"
TITLE_FAIL_DETAIL=""
while IFS= read -r file; do
  # Extract title: handle compressed HTML - find content between <title> and </title>
  title_raw=$(sed -n 's/.*<title[^>]*>\([^<]*\)<\/title>.*/\1/p' "$file" 2>/dev/null | head -1)
  if [ -z "$title_raw" ]; then
    TITLE_FAIL_DETAIL="$TITLE_FAIL_DETAIL\n   $file: Kein <title> gefunden"
  else
    # Decode common HTML entities for accurate character count
    title=$(echo "$title_raw" | sed 's/&amp;/\&/g;s/&ouml;/ö/g;s/&auml;/ä/g;s/&uuml;/ü/g;s/&szlig;/ß/g;s/&Ouml;/Ö/g;s/&Auml;/Ä/g;s/&Uuml;/Ü/g;s/&#[0-9]*;//g;s/&ndash;/–/g;s/&mdash;/—/g')
    len=${#title}
    if [ "$len" -gt 58 ]; then
      TITLE_FAIL_DETAIL="$TITLE_FAIL_DETAIL\n   $file: $len Zeichen (\"$title\")"
    fi
  fi
done < "$ALL_HTML_FILE"

if [ -z "$TITLE_FAIL_DETAIL" ]; then
  check pass "(b) Jede Seite hat Title <= 58 Zeichen"
else
  echo "$FAIL (b) Title zu lang oder fehlend"
  printf "$TITLE_FAIL_DETAIL\n"
  ERRORS=$((ERRORS + 1))
fi

# ==========================================================================
# (c) Jede Seite hat Meta Description <= 155 Zeichen
# ==========================================================================
echo "--- (c) Meta Description <= 155 Zeichen ---"
DESC_FAIL_DETAIL=""
while IFS= read -r file; do
  # Try name="description" content="..." pattern
  desc=$(sed -n 's/.*name="description"[[:space:]]*content="\([^"]*\)".*/\1/p' "$file" 2>/dev/null | head -1)
  # Also try content="..." name="description" (reverse order)
  if [ -z "$desc" ]; then
    desc=$(sed -n 's/.*content="\([^"]*\)"[[:space:]]*name="description".*/\1/p' "$file" 2>/dev/null | head -1)
  fi
  if [ -z "$desc" ]; then
    DESC_FAIL_DETAIL="$DESC_FAIL_DETAIL\n   $file: Keine Meta Description gefunden"
  else
    len=${#desc}
    if [ "$len" -gt 155 ]; then
      DESC_FAIL_DETAIL="$DESC_FAIL_DETAIL\n   $file: $len Zeichen"
    fi
  fi
done < "$ALL_HTML_FILE"

if [ -z "$DESC_FAIL_DETAIL" ]; then
  check pass "(c) Jede Seite hat Meta Description <= 155 Zeichen"
else
  echo "$FAIL (c) Meta Description zu lang oder fehlend"
  printf "$DESC_FAIL_DETAIL\n"
  ERRORS=$((ERRORS + 1))
fi

# ==========================================================================
# (d) Jede Seite hat Canonical mit https + Trailing Slash
# ==========================================================================
echo "--- (d) Canonical: https + Trailing Slash ---"
CANON_FAIL_DETAIL=""
while IFS= read -r file; do
  # Try rel="canonical" href="..."
  canonical=$(sed -n 's/.*rel="canonical"[[:space:]]*href="\([^"]*\)".*/\1/p' "$file" 2>/dev/null | head -1)
  # Also try href="..." rel="canonical"
  if [ -z "$canonical" ]; then
    canonical=$(sed -n 's/.*href="\([^"]*\)"[[:space:]]*rel="canonical".*/\1/p' "$file" 2>/dev/null | head -1)
  fi
  if [ -z "$canonical" ]; then
    CANON_FAIL_DETAIL="$CANON_FAIL_DETAIL\n   $file: Kein Canonical gefunden"
  else
    case "$canonical" in
      https://*) ;; # OK
      *) CANON_FAIL_DETAIL="$CANON_FAIL_DETAIL\n   $file: Canonical ohne https ($canonical)" ;;
    esac
    case "$canonical" in
      */) ;; # OK
      *) CANON_FAIL_DETAIL="$CANON_FAIL_DETAIL\n   $file: Canonical ohne Trailing Slash ($canonical)" ;;
    esac
  fi
done < "$ALL_HTML_FILE"

if [ -z "$CANON_FAIL_DETAIL" ]; then
  check pass "(d) Jede Seite hat Canonical mit https + Trailing Slash"
else
  echo "$FAIL (d) Canonical fehlerhaft"
  printf "$CANON_FAIL_DETAIL\n"
  ERRORS=$((ERRORS + 1))
fi

# ==========================================================================
# (e) Jede Seite hat exakt 1x H1
# ==========================================================================
echo "--- (e) Exakt 1x H1 pro Seite ---"
H1_FAIL_DETAIL=""
while IFS= read -r file; do
  h1_count=$(grep -oi '<h1' "$file" | wc -l | tr -d ' ')
  if [ "$h1_count" -ne 1 ]; then
    H1_FAIL_DETAIL="$H1_FAIL_DETAIL\n   $file: $h1_count H1-Tags"
  fi
done < "$ALL_HTML_FILE"

if [ -z "$H1_FAIL_DETAIL" ]; then
  check pass "(e) Jede Seite hat exakt 1x H1"
else
  echo "$FAIL (e) H1-Anzahl inkorrekt"
  printf "$H1_FAIL_DETAIL\n"
  ERRORS=$((ERRORS + 1))
fi

# ==========================================================================
# (f) Homepage hat KEIN AggregateRating
# ==========================================================================
echo "--- (f) Homepage: kein AggregateRating ---"
if grep -qi "AggregateRating" "$DIST/index.html" 2>/dev/null; then
  check fail "(f) Homepage hat KEIN AggregateRating" "AggregateRating auf Homepage gefunden!"
else
  check pass "(f) Homepage hat KEIN AggregateRating"
fi

# ==========================================================================
# (g) Potsdam/Kleinmachnow: areaServed != "Berlin"
# ==========================================================================
echo "--- (g) Potsdam/Kleinmachnow: areaServed != Berlin ---"
AREA_FAIL_DETAIL=""
for file in \
  "$DIST/wohnungsaufloesung-potsdam/index.html" \
  "$DIST/wohnungsaufloesung-kleinmachnow/index.html" \
  "$DIST/brandenburg-potsdam-umland/index.html"; do
  if [ -f "$file" ]; then
    # Extract JSON-LD and check for areaServed with value "Berlin"
    # Use sed to extract JSON-LD blocks, then check for "areaServed" near "Berlin"
    jsonld=$(sed -n 's/.*<script type="application\/ld+json">\(.*\)<\/script>.*/\1/p' "$file" 2>/dev/null || true)
    if echo "$jsonld" | grep -q '"areaServed"' 2>/dev/null; then
      # Check if areaServed value is exactly "Berlin" (not "Potsdam" etc.)
      if echo "$jsonld" | grep -q '"areaServed"[[:space:]]*:[[:space:]]*"Berlin"' 2>/dev/null; then
        AREA_FAIL_DETAIL="$AREA_FAIL_DETAIL\n   $file: areaServed = \"Berlin\" (sollte Brandenburg sein)"
      fi
      # Check nested object form: "areaServed": { ... "name": "Berlin" ... }
      if echo "$jsonld" | grep -q '"areaServed"' 2>/dev/null && \
         echo "$jsonld" | sed -n '/areaServed/,/}/p' 2>/dev/null | grep -q '"name"[[:space:]]*:[[:space:]]*"Berlin"' 2>/dev/null; then
        AREA_FAIL_DETAIL="$AREA_FAIL_DETAIL\n   $file: areaServed.name = \"Berlin\" (sollte Brandenburg sein)"
      fi
    fi
  fi
done

if [ -z "$AREA_FAIL_DETAIL" ]; then
  check pass "(g) Potsdam/Kleinmachnow: areaServed != Berlin"
else
  echo "$FAIL (g) areaServed fehlerhaft"
  printf "$AREA_FAIL_DETAIL\n"
  ERRORS=$((ERRORS + 1))
fi

# ==========================================================================
# (h) NAP konsistent: "030 585 816 730" auf jeder Seite
# ==========================================================================
echo "--- (h) NAP: Telefonnummer auf jeder Seite ---"
PHONE_FAIL_DETAIL=""
while IFS= read -r file; do
  if ! grep -q "030 585 816 730" "$file" 2>/dev/null; then
    PHONE_FAIL_DETAIL="$PHONE_FAIL_DETAIL\n   $file"
  fi
done < "$ALL_HTML_FILE"

if [ -z "$PHONE_FAIL_DETAIL" ]; then
  check pass "(h) NAP: \"030 585 816 730\" auf jeder Seite"
else
  echo "$FAIL (h) Telefonnummer fehlt auf Seiten"
  printf "$PHONE_FAIL_DETAIL\n"
  ERRORS=$((ERRORS + 1))
fi

# ==========================================================================
# (i) NAP: "Freiraum-Auflösungen GmbH" auf jeder Seite
# ==========================================================================
echo "--- (i) NAP: Firmenname auf jeder Seite ---"
NAME_FAIL_DETAIL=""
while IFS= read -r file; do
  # Check for UTF-8 string, HTML entity, and JSON unicode escape
  if ! grep -q "Freiraum-Auflösungen GmbH" "$file" 2>/dev/null && \
     ! grep -q 'Freiraum-Aufl\&ouml;sungen GmbH' "$file" 2>/dev/null && \
     ! grep -q 'Freiraum-Aufl\\u00f6sungen GmbH' "$file" 2>/dev/null; then
    NAME_FAIL_DETAIL="$NAME_FAIL_DETAIL\n   $file"
  fi
done < "$ALL_HTML_FILE"

if [ -z "$NAME_FAIL_DETAIL" ]; then
  check pass "(i) NAP: \"Freiraum-Auflösungen GmbH\" auf jeder Seite"
else
  echo "$FAIL (i) Firmenname fehlt auf Seiten"
  printf "$NAME_FAIL_DETAIL\n"
  ERRORS=$((ERRORS + 1))
fi

# ==========================================================================
# (j) Keine Broken internen Links
# ==========================================================================
echo "--- (j) Keine Broken internen Links ---"
BROKEN_FILE=$(mktemp)
while IFS= read -r file; do
  # Extract all internal href values (starting with /)
  # Use sed to extract href="/..." patterns
  grep -o 'href="/[^"#]*"' "$file" 2>/dev/null | sed 's/href="//;s/"$//' | while IFS= read -r link; do
    [ -z "$link" ] && continue
    # Normalize: /path/ -> dist/path/index.html, / -> dist/index.html
    if [ "$link" = "/" ]; then
      target="$DIST/index.html"
    else
      clean="${link%/}"
      if [ -f "$DIST$clean" ]; then
        target="$DIST$clean"
      elif [ -f "$DIST${clean}/index.html" ]; then
        target="$DIST${clean}/index.html"
      elif [ -f "$DIST${link}index.html" ]; then
        target="$DIST${link}index.html"
      else
        target="$DIST$clean/index.html"
      fi
    fi
    if [ ! -f "$target" ]; then
      echo "$file -> $link" >> "$BROKEN_FILE"
    fi
  done
done < "$ALL_HTML_FILE"

BROKEN_COUNT=0
if [ -f "$BROKEN_FILE" ]; then
  # Deduplicate
  sort -u "$BROKEN_FILE" > "${BROKEN_FILE}.sorted"
  BROKEN_COUNT=$(wc -l < "${BROKEN_FILE}.sorted" | tr -d ' ')
  rm -f "${BROKEN_FILE}.sorted"
fi

if [ "$BROKEN_COUNT" -eq 0 ]; then
  check pass "(j) Keine Broken internen Links"
else
  BROKEN_DETAIL=$(sort -u "$BROKEN_FILE" | head -20)
  echo "$FAIL (j) $BROKEN_COUNT Broken interne Links gefunden"
  echo "   $BROKEN_DETAIL"
  ERRORS=$((ERRORS + 1))
fi
rm -f "$BROKEN_FILE"

# ==========================================================================
# (k) "Küchenentsorgung" NIRGENDS auf der Website (0 Treffer)
# ==========================================================================
echo "--- (k) Küchenentsorgung nirgends ---"
KITCHEN_HITS=$(grep -rl "Küchenentsorgung" "$DIST" --include="*.html" 2>/dev/null || true)
KITCHEN_HITS2=$(grep -rl "K&uuml;chenentsorgung" "$DIST" --include="*.html" 2>/dev/null || true)
KITCHEN_ALL="${KITCHEN_HITS}${KITCHEN_HITS2}"

if [ -z "$KITCHEN_ALL" ]; then
  check pass "(k) \"Küchenentsorgung\" nirgends auf der Website"
else
  check fail "(k) \"Küchenentsorgung\" gefunden" "$KITCHEN_ALL"
fi

# ==========================================================================
# (l) "Tapete entfernen" NIRGENDS auf der Website (0 Treffer)
# ==========================================================================
echo "--- (l) Tapete entfernen nirgends ---"
TAPETE_HITS=$(grep -rli "Tapete entfernen" "$DIST" --include="*.html" 2>/dev/null || true)

if [ -z "$TAPETE_HITS" ]; then
  check pass "(l) \"Tapete entfernen\" nirgends auf der Website"
else
  check fail "(l) \"Tapete entfernen\" gefunden" "$TAPETE_HITS"
fi

# ==========================================================================
# (m) Impressum + Datenschutz: robots=noindex
# ==========================================================================
echo "--- (m) Impressum + Datenschutz: noindex ---"
NOINDEX_FAIL_DETAIL=""
for file in "$DIST/impressum/index.html" "$DIST/datenschutz/index.html"; do
  if [ -f "$file" ]; then
    if ! grep -qi 'name="robots"' "$file" 2>/dev/null; then
      NOINDEX_FAIL_DETAIL="$NOINDEX_FAIL_DETAIL\n   $file: Kein robots Meta-Tag"
    elif ! grep -qi 'noindex' "$file" 2>/dev/null; then
      NOINDEX_FAIL_DETAIL="$NOINDEX_FAIL_DETAIL\n   $file: robots Meta-Tag ohne noindex"
    fi
  else
    NOINDEX_FAIL_DETAIL="$NOINDEX_FAIL_DETAIL\n   $file: Datei nicht gefunden"
  fi
done

if [ -z "$NOINDEX_FAIL_DETAIL" ]; then
  check pass "(m) Impressum + Datenschutz: robots=noindex"
else
  echo "$FAIL (m) noindex fehlt"
  printf "$NOINDEX_FAIL_DETAIL\n"
  ERRORS=$((ERRORS + 1))
fi

# ==========================================================================
# (n) Sitemap: kein Impressum, kein Datenschutz, kein 404
# ==========================================================================
echo "--- (n) Sitemap: keine verbotenen Seiten ---"
SITEMAP_FAIL_DETAIL=""
SITEMAP_FILES=$(find "$DIST" -name "sitemap*.xml" 2>/dev/null)

if [ -z "$SITEMAP_FILES" ]; then
  SITEMAP_FAIL_DETAIL="Keine Sitemap gefunden"
else
  SITEMAP_CONTENT=""
  for sf in $SITEMAP_FILES; do
    SITEMAP_CONTENT="$SITEMAP_CONTENT$(cat "$sf")"
  done

  if echo "$SITEMAP_CONTENT" | grep -q "/impressum/" 2>/dev/null; then
    SITEMAP_FAIL_DETAIL="$SITEMAP_FAIL_DETAIL Impressum in Sitemap gefunden."
  fi
  if echo "$SITEMAP_CONTENT" | grep -q "/datenschutz/" 2>/dev/null; then
    SITEMAP_FAIL_DETAIL="$SITEMAP_FAIL_DETAIL Datenschutz in Sitemap gefunden."
  fi
  if echo "$SITEMAP_CONTENT" | grep -q "/404" 2>/dev/null; then
    SITEMAP_FAIL_DETAIL="$SITEMAP_FAIL_DETAIL 404 in Sitemap gefunden."
  fi
fi

if [ -z "$SITEMAP_FAIL_DETAIL" ]; then
  check pass "(n) Sitemap: kein Impressum, kein Datenschutz, kein 404"
else
  check fail "(n) Sitemap enthält verbotene Seiten" "$SITEMAP_FAIL_DETAIL"
fi

# ==========================================================================
# (o) robots.txt vorhanden
# ==========================================================================
echo "--- (o) robots.txt vorhanden ---"
if [ -f "$DIST/robots.txt" ]; then
  check pass "(o) robots.txt vorhanden"
else
  check fail "(o) robots.txt vorhanden" "dist/robots.txt nicht gefunden"
fi

# ==========================================================================
# ZUSAMMENFASSUNG
# ==========================================================================
echo ""
echo "========================================"
if [ "$ERRORS" -eq 0 ]; then
  echo " $PASS ALLE CHECKS BESTANDEN ($HTML_COUNT Seiten geprüft)"
else
  echo " $FAIL $ERRORS CHECK(S) FEHLGESCHLAGEN"
fi
echo "========================================"

if [ "$ERRORS" -gt 0 ]; then
  exit 1
fi
exit 0
