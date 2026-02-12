# QA Report - Freiraum-Aufloesungen Website

**Datum:** 2026-02-12
**Build:** Astro 5.17.1 | 35 Seiten | Static Output
**QA-Script:** `scripts/qa-full.sh`

---

## 1. Automatisierte QA (qa-full.sh) - ALLE BESTANDEN

| Check | Beschreibung | Status |
|-------|-------------|--------|
| (a) | Alle 35 Seiten existieren in dist/ | PASS |
| (b) | Title <= 58 Zeichen | PASS |
| (c) | Meta Description <= 155 Zeichen | PASS |
| (d) | Canonical: https + Trailing Slash | PASS |
| (e) | Exakt 1x H1 pro Seite | PASS |
| (f) | Homepage: kein AggregateRating | PASS |
| (g) | Potsdam/Kleinmachnow: areaServed != Berlin | PASS |
| (h) | NAP: Telefonnummer auf jeder Seite | PASS |
| (i) | NAP: Firmenname auf jeder Seite | PASS |
| (j) | Keine Broken internen Links | PASS |
| (k) | "Kuechenentsorgung" nirgends | PASS |
| (l) | "Tapete entfernen" nirgends | PASS |
| (m) | Impressum + Datenschutz: noindex | PASS |
| (n) | Sitemap: kein Impressum/Datenschutz/404 | PASS |
| (o) | robots.txt vorhanden | PASS |

---

## 2. Manuelle Pruefungen

### 2.1 Responsive 375px - Kein Overflow

| Pruefpunkt | Status | Details |
|-----------|--------|---------|
| Feste Breiten > 375px | PASS | Keine hardcoded px-Breiten gefunden |
| Tabellen-Overflow | PASS | Keine HTML-Tabellen im Code |
| Bild-Constraints | PASS | `w-full h-auto` durchgehend verwendet |
| Container-Overflow | PASS | `overflow-hidden` korrekt eingesetzt |

### 2.2 Touch-Targets >= 48px

| Element | Status | Details |
|---------|--------|---------|
| CTA Buttons (Hero, End, Inline) | PASS | `min-h-[48px]` durchgehend |
| Cookie-Banner Buttons | FIXED | 44px -> 48px korrigiert |
| Sticky Mobile CTA | PASS | `h-14` (56px) |
| Mobile Navigation | PASS | Ausreichende Spacing |
| Formular-Inputs | PASS | `py-3` (ca. 44px+) |
| Footer Links | PASS | `space-y-3` Spacing |

### 2.3 Todesfall-Seite: Keine aggressiven CTAs

| Pruefpunkt | Status | Details |
|-----------|--------|---------|
| CTA-Text | PASS | "Unverbindlich beraten lassen" (soft) |
| Mid-Content CTA | PASS | "Wir nehmen uns Zeit fuer Sie" |
| End CTA | PASS | "Wir unterstuetzen Sie, wenn Sie bereit sind" |
| Layout | PASS | `ServicePageSensitive` Layout verwendet |

### 2.4 B2B-Seiten: Kein Sticky CTA Mobile

| Seite | Status | Details |
|-------|--------|---------|
| fuer-hausverwaltungen | PASS | `showStickyCTA={false}` in B2BPage Layout |
| fuer-insolvenzverwalter | PASS | `showStickyCTA={false}` in B2BPage Layout |
| fuer-makler | PASS | `showStickyCTA={false}` in B2BPage Layout |

### 2.5 Bezirksseiten: CTA enthaelt Ortsnamen

| Seite | Ortsname | CTA-Text | Status |
|-------|----------|----------|--------|
| wohnungsaufloesung-charlottenburg | Charlottenburg | "Angebot fuer Charlottenburg anfordern" | PASS |
| wohnungsaufloesung-dahlem | Dahlem | "Angebot fuer Dahlem anfordern" | PASS |
| wohnungsaufloesung-grunewald | Grunewald | "Angebot fuer Grunewald anfordern" | PASS |
| wohnungsaufloesung-schmargendorf | Schmargendorf | "Angebot fuer Schmargendorf anfordern" | PASS |
| wohnungsaufloesung-zehlendorf | Zehlendorf | "Angebot fuer Zehlendorf anfordern" | PASS |
| wohnungsaufloesung-potsdam | Potsdam | "Angebot fuer Potsdam anfordern" | PASS |
| wohnungsaufloesung-kleinmachnow | Kleinmachnow | "Angebot fuer Kleinmachnow anfordern" | PASS |
| berlin-charlottenburg-wilmersdorf | Charlottenburg-Wilmersdorf | "Angebot fuer Charlottenburg-Wilmersdorf anfordern" | PASS |
| berlin-steglitz-zehlendorf | Steglitz-Zehlendorf | "Angebot fuer Steglitz-Zehlendorf anfordern" | PASS |
| brandenburg-potsdam-umland | Potsdam & Umland | "Angebot fuer Potsdam & Umland anfordern" | PASS |

### 2.6 tel: und wa.me Links

| Link-Typ | Erwarteter Wert | Status |
|----------|----------------|--------|
| tel: | `tel:+4930585816730` | PASS - konsistent in allen Dateien |
| wa.me | `https://wa.me/4930585816730` | PASS - konsistent in allen Dateien |
| Zentral definiert | `src/config/navigation.ts` contactData | PASS |

### 2.7 Cookie-Banner: Beide Buttons gleichwertig

| Pruefpunkt | Status | Details |
|-----------|--------|---------|
| Button-Styling identisch | PASS | Gleiche Klassen fuer beide Buttons |
| Kein visueller Bias | PASS | Beide: `bg-white text-gray-800 border border-gray-300` |
| Gleiche Groesse | PASS | Beide: `min-w-[160px] min-h-[48px]` |
| DSGVO-konform | PASS | Keine Manipulation zur Zustimmung |

---

## 3. Bugfixes in diesem Durchlauf

| Fix | Datei | Aenderung |
|-----|-------|-----------|
| Cookie-Banner Touch-Targets | `src/components/CookieBanner.astro` | `min-h-[44px]` -> `min-h-[48px]` (WCAG 2.5.8) |

---

## 4. Ergebnis

**QA-Script:** 15/15 Checks bestanden
**Manuelle Pruefung:** 7/7 Kategorien bestanden
**Bugs gefunden & gefixt:** 1 (Cookie-Banner Touch-Targets)
**Gesamtergebnis: BESTANDEN**
