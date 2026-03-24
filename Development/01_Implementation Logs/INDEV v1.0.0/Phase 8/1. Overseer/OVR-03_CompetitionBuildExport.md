# OVR-03 — Competition Build Export

**Phase:** Phase 8 — Testing & Competition Build
**Team:** Overseer — Head Office
**Status:** `[ ] PENDING`
**Depends on:** OVR-02
**Blocks:** None

---

## Scope
Produce the final competition submission build — Windows executable and optional Web export. Configure build settings, test exported builds, prepare submission materials.

## Acceptance Criteria
- [ ] Godot export templates installed for Windows and HTML5
- [ ] Windows build: `.exe` + `.pck` exported to `build/windows/`
- [ ] Windows build runs standalone without Godot editor installed
- [ ] (Optional) Web build: HTML5 exported to `build/web/` — test in Chrome and Firefox
- [ ] Build includes all assets, scenes, data files, translations
- [ ] Build does NOT include: `user_data/` (generated at runtime), `.git/`, `Development/`
- [ ] API key configuration: included as empty template `api_config.json` with instructions
- [ ] README.txt in build folder: launch instructions, API key setup, system requirements
- [ ] Competition submission files prepared per TMH2026 format:
  - `TeamName_PitchDeck.pdf` — 10-30 slides
  - `TeamName_VideoPitch.mp4` — max 5 minutes
- [ ] Final build tested: launch → tutorial → complete scenario → AI review → dashboard → exit

## Boundaries — Do NOT Touch
- Do NOT include API keys in the build — provide configuration template only
- Do NOT modify gameplay during build preparation

## Notes
- TMH2026 deadline: April 2nd, 2026 for qualifying round submission
- Pitch deck and video are team responsibility — this ticket ensures the game build is ready
