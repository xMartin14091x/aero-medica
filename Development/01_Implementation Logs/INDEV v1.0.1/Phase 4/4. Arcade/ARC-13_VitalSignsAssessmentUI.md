# ARC-13 — Vital Signs Assessment UI

**Phase:** Phase 4 — OPQRST & Vital Signs
**Team:** Arcade — Frontend/Creative
**Status:** `[x] Complete`
**Depends on:** MON-11
**Blocks:** None

---

## Scope
Add vital sign assessment options to the Exam tab of `PatientInteractionUI`. Display results with color-coded normal/abnormal/critical ranges. Handle equipment-gating feedback when player lacks required tools.

## Implementation Detail

### Exam Tab Expansion
Currently the Exam tab shows DRSABCDE assessment buttons. Add a "Vital Signs" subsection below the existing checks with 8 new buttons:

| Button Label | Assessment Action | Equipment Required |
|-------------|------------------|-------------------|
| "Heart Rate" | `CHECK_HEART_RATE` | None (palpation) |
| "Blood Pressure" | `CHECK_BLOOD_PRESSURE` | BP Cuff |
| "SpO2" | `CHECK_SPO2` | Pulse Oximeter |
| "Pupils" | `CHECK_PUPILS` | Penlight |
| "Temperature" | `CHECK_TEMPERATURE` | Thermometer |
| "Blood Glucose" | `CHECK_BLOOD_GLUCOSE` | Glucometer |
| "Cap Refill" | `CHECK_CAPILLARY_REFILL` | None |
| "Skin Assessment" | `CHECK_SKIN` | None |

### Color-Coded Result Display
Use `VITAL_RANGES` from `MedicalStateComponent` (MON-11) to color-code results:
- **Green:** Within normal range
- **Yellow:** Abnormal but not critical
- **Red:** Critical value — requires immediate attention

Display format in the assessment result area:
```
Heart Rate: 118 BPM [TACHYCARDIA]     ← yellow text
Blood Pressure: 82/55 mmHg [HYPOTENSION]  ← red text
SpO2: 97% [NORMAL]                      ← green text
```

### Equipment-Gating Feedback
When player attempts an equipment-gated assessment without the required tool:
- Button still visible but shows a small equipment icon indicator
- On click without equipment: display message in result area: "Requires: [Equipment Name] — check your medical bag"
- Do NOT disable the button entirely — let the player try and learn they need equipment

### Skin Assessment Display
Skin check returns 3 components (color, temperature, moisture). Display as:
```
Skin: Pale, Cool, Diaphoretic [SHOCK SIGNS]
```

### Visual Layout
- Separate the existing ABCDE checks from new Vital Signs with a divider or section header
- Section header: "Primary Survey (ABCDE)" above existing, "Vital Signs" above new
- Vital sign buttons use a slightly different style (e.g., monospace font for numeric results)

## Acceptance Criteria
- [x]8 new vital sign assessment buttons visible in Exam tab
- [x]Results display with correct color-coding (green/yellow/red based on ranges)
- [x]Equipment-gating feedback displays when player lacks required tool
- [x]Equipment icon indicators on buttons that require tools
- [x]Skin assessment displays all 3 components
- [x]Section headers separate ABCDE from Vital Signs
- [x]Results logged to telemetry via existing `assessment_performed` signal
- [x]Existing ABCDE assessment buttons unchanged

## Boundaries — Do NOT Touch
- Do not modify existing ABCDE assessment button behavior
- Do not modify Patient/Stabilize/Differential tabs
- Do not modify `MedicalStateComponent` fields (that's MON-11)

## Notes
- Clinical reference: Medica Consultation Log #01, Part 2B
- Normal ranges sourced from BUMED Fundamental Concepts — Vital Signs section
- Key UX principle: color-coding teaches normal vs. abnormal recognition — core EMS skill
