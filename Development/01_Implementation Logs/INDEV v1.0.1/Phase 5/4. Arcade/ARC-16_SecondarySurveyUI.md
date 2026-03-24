# ARC-16 — Secondary Survey Body-Region Examination UI

**Phase:** Phase 5 — ECG, GCS & Secondary Survey
**Team:** Arcade — Frontend/Creative
**Status:** `[x] Complete`
**Depends on:** MON-15 (secondary survey system)
**Blocks:** None

---

## Scope
Create a body-region examination interface for the secondary survey (head-to-toe assessment). Player selects body regions from a menu to examine, each returning clinical findings text. Track examination completeness with visual feedback.

## Implementation Detail

### Secondary Survey Panel
Add "Secondary Survey" section to the Exam tab, below Vital Signs:

```
┌─────────────────────────────────────────────┐
│  SECONDARY SURVEY (Head-to-Toe)       75%   │
│ ──────────────────────────────────────────── │
│                                             │
│  [✓] Head / Face      "4cm laceration..."   │
│  [✓] Neck             "JVD present..."      │
│  [✓] Chest            "Flail segment..."    │
│  [ ] Abdomen          ← not yet examined    │
│  [ ] Pelvis                                 │
│  [✓] Back             "No injuries..."      │
│  [ ] Extremities                            │
│                                             │
│  Progress: 4/7 regions examined             │
└─────────────────────────────────────────────┘
```

### Region Buttons
7 buttons, one per body region:
- **Unexamined:** Normal button style, clickable
- **Examined:** Checkmark, greyed button, findings text shown as tooltip or inline preview
- Each button click triggers `SecondarySurveyManager.examine_region()` and displays the full findings text

### Findings Display
When a region is clicked:
- Show the findings text in a result area below the buttons (or as an expanding section)
- Text uses color coding:
  - **Normal findings:** Grey/dim text ("No abnormalities detected")
  - **Abnormal findings:** White/bright text with key terms highlighted
  - **Critical findings:** Red text for life-threatening discoveries (e.g., "Unstable pelvis", "Flail chest", "No distal pulse")

### Critical Finding Alerts
Certain findings should trigger a prominent alert:
- Pelvic instability → "⚠ Pelvic fracture — apply pelvic binder"
- Absent distal pulse → "⚠ Vascular compromise — restore alignment"
- Flail chest → "⚠ Flail segment — support breathing"
- JVD + tracheal deviation → "⚠ Consider tension pneumothorax"

These alerts are teaching prompts, not blockers.

### Completion Tracking
- Progress bar or fraction (e.g., "4/7 regions examined")
- When all 7 regions examined, show "Secondary Survey Complete ✓"
- Examination order tracked for debrief (head-to-toe is the correct systematic approach)

### Gating
Secondary survey button should be:
- **Greyed out** if primary survey (ABCDE) has not been completed on this patient
- Tooltip: "Complete primary survey (ABCDE) first"
- This enforces the correct clinical workflow: stabilize life threats before detailed examination

### Layout Integration
Add to Exam tab below the Vital Signs section:
```
Primary Survey (ABCDE):
  [Check Airway] [Check Breathing] [Check Pulse] [Check Consciousness] [Check Bleeding]

Vital Signs:
  [HR] [BP] [SpO2] [Pupils] [Temp] [Glucose] [Cap Refill] [Skin]

Neurological:
  [GCS Assessment]

Secondary Survey:                    ← NEW section
  [Head] [Neck] [Chest] [Abdomen] [Pelvis] [Back] [Extremities]
  Progress: 0/7
```

## Acceptance Criteria
- [x]7 body-region buttons displayed in Secondary Survey section
- [x]Clicking a region shows clinical findings text from scenario data
- [x]Examined regions show checkmark and findings preview
- [x]Color-coded findings: normal (dim), abnormal (bright), critical (red)
- [x]Critical finding alerts displayed as teaching prompts
- [x]Completion tracking (X/7 regions examined)
- [x]Secondary survey greyed out until primary survey (ABCDE) complete
- [x]Examination order logged to telemetry
- [x]Default "No abnormalities" for regions without scenario data

## Boundaries — Do NOT Touch
- Do not modify `SecondarySurveyManager` (that's MON-15)
- Do not modify Primary Survey or Vital Signs sections
- Do not modify Patient/Stabilize/Differential tabs

## Notes
- Clinical reference: Medica Consultation Log #01, Part 2E
- Head-to-toe is the correct systematic approach — debrief should reward this order
- The secondary survey is where the player discovers injuries beyond the obvious ones — it's the "detective" phase of patient assessment
