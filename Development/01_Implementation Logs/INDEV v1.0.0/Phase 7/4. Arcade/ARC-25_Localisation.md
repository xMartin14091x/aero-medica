# ARC-25 — Thai + English Localisation

**Phase:** Phase 7 — UI/UX & Localisation
**Team:** Arcade — Frontend/Creative
**Status:** `[x] Complete`
**Depends on:** All UI tickets (ARC-01 through ARC-24)
**Blocks:** None

---

## Scope
Implement full Thai/English localisation — externalise all UI strings, create translation CSV files, integrate with Godot's Translation system. Thai is the primary language.

## Acceptance Criteria
- [x] `data/translations/translations.csv` — master translation file with key, th, en columns (155 entries)
- [x] All Phase 7 UI scripts use tr() for all visible text
- [x] Menu text: Start Tutorial, Select Scenario, Dashboard, Settings, Quit, Back, Confirm, Cancel
- [x] Gameplay text: 5 assessment actions, 4 triage labels, 5 equipment names, HUD labels, 5 hint messages
- [x] Debrief/review text: section headers, PASS/FAIL, loading/error states, Continue button
- [x] Dashboard text: 5 axis names, score/rate/attempt labels, export label, weakness message
- [x] Settings text: Audio/Language/Controls/Accessibility tabs, slider labels, toggle labels
- [x] Thai font: standard Godot rendering ready (Noto Sans Thai integration via theme)
- [x] LocalisationManager: CSV loading, TranslationServer registration, locale_changed signal for instant switching
- [x] 155 translation keys covering all UI categories (menus, scenarios, HUD, medical, dashboard, settings)
- [x] Test: LocalisationManager loads CSV at startup, tr() returns correct locale text, toggle_locale() instant switch

## Boundaries — Do NOT Touch
- Do NOT translate AI review output — it responds in whatever language the prompt uses
- Do NOT translate scenario data (medical terms) — use English medical terminology with Thai UI labels
- Do NOT implement additional languages beyond Thai + English

## Notes
- Thai medical terminology: use standard Thai EMS terms (e.g., การคัดกรอง for triage, ช่วยฟื้นคืนชีพ for CPR)
- Font: [Noto Sans Thai](https://fonts.google.com/noto/specimen/Noto+Sans+Thai) (OFL license, free)
