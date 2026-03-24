# ARC-26 — Visual Polish Pass

**Phase:** Phase 8 — Testing & Competition Build
**Team:** Arcade — Frontend/Creative
**Status:** `[ ] PENDING`
**Depends on:** OVR-02 (QA feedback)
**Blocks:** OVR-03

---

## Scope
Final visual polish — replace any remaining placeholder assets, ensure visual consistency across all scenes, fix UI alignment issues, and verify the "clean low-poly realistic" art direction is cohesive.

## Acceptance Criteria
- [ ] **No placeholder meshes remain** — all coloured boxes replaced with actual 3D models or styled low-poly equivalents
- [ ] **Consistent art style** — all imported assets match the same visual quality level (no mix of photorealistic and low-poly)
- [ ] **Colour palette** — verify consistent use of colours across all UI screens (using Godot Theme)
- [ ] **Typography** — Thai font (Noto Sans Thai) renders correctly at all sizes, English fallback font matches style
- [ ] **UI alignment** — all buttons, labels, and panels properly aligned (no overlapping, no clipping at screen edges)
- [ ] **Scene lighting** — consistent lighting quality across all 5 scenario environments
- [ ] **Particle effects** — fire, smoke, bleeding effects look polished and appropriate
- [ ] **Screenshots** — capture 5-10 high-quality screenshots for pitch deck (each scenario + dashboard + AI review)
- [ ] **Comparison check** — side-by-side all scenarios for visual consistency
- [ ] Test: play through entire game → visuals are cohesive and professional → suitable for competition presentation

## Boundaries — Do NOT Touch
- Do NOT change gameplay or scoring — visual-only changes
- Do NOT add new features — polish existing visuals only

## Notes
- **This is the last chance to import final 3D assets.** After this ticket, the build is locked for export
- Priority: focus on what judges will SEE — main menu, first scenario (RTA), AI review screen, dashboard radar chart
