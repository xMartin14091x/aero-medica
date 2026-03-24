# ARC-14 — ECG Monitor Overlay UI (Image-Based)

**Phase:** Phase 5 — ECG, GCS & Secondary Survey
**Team:** Arcade — Frontend/Creative
**Status:** `[x] Complete`
**Depends on:** MON-13 (ECG rhythm system + image loading)
**Blocks:** None

---

## Scope
Create the ECG monitor display overlay in `PatientInteractionUI`. Shows the rhythm strip as an IMAGE (not text), with rhythm identification mechanic for ALS scenarios. Uses placeholder images initially — real ECG strip images will be provided by Chief Manager later.

## Implementation Detail

### ECG Display Component
Create an ECG display area within the Exam tab or as a separate overlay panel:

**Layout:**
```
┌──────────────────────────────────────────┐
│  CARDIAC MONITOR                    [X]  │
│ ─────────────────────────────────────── │
│ ┌──────────────────────────────────────┐ │
│ │                                      │ │
│ │    [RHYTHM STRIP IMAGE HERE]         │ │  ← TextureRect, 4:1 aspect ratio
│ │                                      │ │
│ └──────────────────────────────────────┘ │
│                                          │
│  HR: 118 BPM    Rhythm: ???              │  ← Rate shown, rhythm hidden until identified
│                                          │
│  ┌─────────────┐ ┌─────────────┐         │
│  │ Normal Sinus│ │ Sinus Tachy │         │
│  ├─────────────┤ ├─────────────┤         │  ← Rhythm identification buttons (ALS only)
│  │    SVT      │ │    VT       │         │
│  ├─────────────┤ ├─────────────┤         │
│  │    VF       │ │  Asystole   │         │
│  ├─────────────┤ ├─────────────┤         │
│  │   AFib      │ │    PEA      │         │
│  └─────────────┘ └─────────────┘         │
│                                          │
│  [RESULT: Correct! / Incorrect]          │
└──────────────────────────────────────────┘
```

### Image Display
- Use `TextureRect` with `expand_mode = KEEP_ASPECT_COVERED` or `FIT_WIDTH`
- Load rhythm image via `ECGRhythmManager.get_rhythm_image(rhythm_key)`
- If image fails to load (placeholder missing), show a fallback: colored rectangle with rhythm name text
- Image should animate/scroll if possible (optional polish — simple left-to-right scroll of the strip gives a "live monitor" feel)

### Two Modes: AED vs. Manual Monitor

**AED Mode (BLS):**
- Player attaches AED → AED auto-analyzes rhythm
- Display shows: rhythm image + "Shock Advised" or "No Shock Advised"
- Player does NOT need to identify the rhythm
- No identification buttons shown

**Manual Monitor Mode (ALS):**
- Player attaches cardiac monitor → rhythm image displayed
- HR shown, but rhythm name is hidden ("Rhythm: ???")
- Player must select the correct rhythm from the button grid
- On selection:
  - **Correct:** "✓ Correct — [Rhythm Name]" in green, rhythm name revealed
  - **Incorrect:** "✗ Incorrect — try again" in red, player can retry (max 2 attempts before revealing answer)
- After identification, treatment options become available

### Placeholder Image System
- Each rhythm has a placeholder PNG at `assets/textures/ecg/[rhythm_key].png`
- Placeholders: simple colored rectangle (e.g., green for normal, red for shockable, grey for asystole) with rhythm name text overlaid
- **Drop-in replacement:** When Chief Manager provides real images, just replace the PNGs at the same paths — no code changes
- Image resolution recommendation: 1024×256 (4:1 strip aspect ratio)

### Integration with PatientInteractionUI
- Add "Cardiac Monitor" button to Exam tab (appears only when cardiac monitor or AED is attached to patient)
- Clicking opens the ECG overlay panel
- ECG panel overlays the PatientInteractionUI content area (like history dialogue does)
- Close button returns to normal Exam tab view

## Acceptance Criteria
- [x]ECG overlay panel created with TextureRect for rhythm strip image
- [x]Rhythm images load from `ECGRhythmManager` via configurable paths
- [x]AED mode: auto-analysis with "Shock Advised" / "No Shock Advised" display
- [x]Manual monitor mode: rhythm identification buttons with correct/incorrect feedback
- [x]Placeholder images created for all 9 rhythms (simple colored rectangles with text)
- [x]Images are drop-in replaceable — swapping PNGs requires zero code changes
- [x]HR readout displayed alongside rhythm strip
- [x]Max 2 incorrect attempts before answer is revealed
- [x]Fallback display when image file is missing (text-based rhythm name)
- [x]"Cardiac Monitor" button only visible when monitor/AED equipment is attached

## Boundaries — Do NOT Touch
- Do not modify `ECGRhythmManager` (that's MON-13)
- Do not modify AED equipment logic (MON-13 handles the auto-analysis)
- Do not modify Patient/Stabilize/Differential tabs

## Notes
- Chief Manager directive: "I prefer to have real images instead of words — I will find the images later. Make it compatible with images and placeholder for now."
- Image path convention: `res://assets/textures/ecg/[rhythm_key].png` — lowercase, underscored
- Clinical reference: Medica Consultation Log #01, Part 2C
- Optional polish: scrolling animation on the rhythm strip to simulate live monitoring
