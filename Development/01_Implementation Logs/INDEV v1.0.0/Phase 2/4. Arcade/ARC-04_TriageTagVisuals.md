# ARC-04 — Triage Tag Visuals

**Phase:** Phase 2 — Medical Protocol System
**Team:** Arcade — Frontend/Creative
**Status:** `[x] Complete`
**Depends on:** SYN-05
**Blocks:** None

---

## Scope
Implement the visual triage tag display on patients — colour-coded 3D labels that appear after the player assigns a tag.

## Acceptance Criteria
- [ ] TriageTagVisual node on PatientBase updated: shows colour-coded tag (Green/Yellow/Red/Black)
- [ ] Tag appears as a small 3D mesh or Label3D floating above patient after assignment
- [ ] Colour mapping: GREEN=#00FF00, YELLOW=#FFFF00, RED=#FF0000, BLACK=#333333
- [ ] Tag is hidden before assignment, visible after
- [ ] Incorrect tag has subtle visual indicator (e.g., slight pulsing) — player should notice something is off without explicit "WRONG" text (stealth assessment principle)
- [ ] Tag is visible from isometric camera distance
- [ ] Test: assign RED tag → red label appears above patient → visible from normal play distance

## Boundaries — Do NOT Touch
- Do NOT implement the triage selection UI — extend ARC-01 action menu to include triage options
- Do NOT implement tag reassignment visuals
