# SYN-15 — Data Export System

**Phase:** Phase 5 — Dashboards & Scoring
**Team:** Syndicate — Backend/Efficiency
**Status:** `[x] Complete`
**Depends on:** SYN-13, SYN-14
**Blocks:** None

---

## Scope
Export performance data as PDF or CSV for institutional record-keeping. Enables instructors to download student performance reports.

## Acceptance Criteria
- [ ] `scripts/dashboard/data_exporter.gd` — handles export functionality
- [ ] CSV export: all session history as tabular data (scenario, date, 5 axes, overall, pass/fail)
- [ ] CSV file saved to user-selected path via Godot's FileDialog
- [ ] JSON export: full session data including telemetry and AI review text
- [ ] Signal: `export_complete(path)`, `export_failed(error)`
- [ ] Export triggered from dashboard UI (button)
- [ ] Test: accumulate 3 sessions → export CSV → file contains correct data → opens in spreadsheet software

## Boundaries — Do NOT Touch
- Do NOT implement PDF generation (complex in GDScript) — CSV and JSON are sufficient for competition
- Do NOT implement remote/cloud export — F11 scope
