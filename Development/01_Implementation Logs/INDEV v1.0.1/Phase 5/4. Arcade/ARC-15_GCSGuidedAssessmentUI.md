# ARC-15 — GCS Guided Assessment UI

**Phase:** Phase 5 — ECG, GCS & Secondary Survey
**Team:** Arcade — Frontend/Creative
**Status:** `[x] Complete`
**Depends on:** MON-14 (GCS assessment system)
**Blocks:** None

---

## Scope
Create a guided 3-step GCS assessment interface within the Exam tab. The player walks through Eye Opening → Verbal Response → Motor Response, selecting the observed response for each component. Score auto-calculates and displays with severity classification and clinical threshold warnings.

## Implementation Detail

### GCS Assessment Flow
When player selects "GCS Assessment" from the Exam tab:

**Step 1 — Eye Opening (E1-4):**
```
┌─────────────────────────────────────┐
│  GCS — Step 1/3: Eye Opening        │
│ ──────────────────────────────────── │
│  Select the patient's eye response: │
│                                     │
│  [4] Spontaneous                    │
│  [3] To Voice                       │
│  [2] To Pain                        │
│  [1] None                           │
│                                     │
│  Current: E? + V? + M? = ?/15       │
└─────────────────────────────────────┘
```

**Step 2 — Verbal Response (V1-5):**
```
┌─────────────────────────────────────┐
│  GCS — Step 2/3: Verbal Response    │
│ ──────────────────────────────────── │
│  Select the patient's verbal resp:  │
│                                     │
│  [5] Oriented                       │
│  [4] Confused                       │
│  [3] Inappropriate Words            │
│  [2] Incomprehensible               │
│  [1] None                           │
│                                     │
│  Current: E4 + V? + M? = ?/15       │
└─────────────────────────────────────┘
```

**Step 3 — Motor Response (M1-6):**
```
┌─────────────────────────────────────┐
│  GCS — Step 3/3: Motor Response     │
│ ──────────────────────────────────── │
│  Select the patient's motor resp:   │
│                                     │
│  [6] Obeys Commands                 │
│  [5] Localizes Pain                 │
│  [4] Withdrawal                     │
│  [3] Abnormal Flexion (Decorticate) │
│  [2] Extension (Decerebrate)        │
│  [1] None                           │
│                                     │
│  Current: E4 + V5 + M? = ?/15      │
└─────────────────────────────────────┘
```

**Result Display:**
```
┌─────────────────────────────────────┐
│  GCS Assessment Complete            │
│ ──────────────────────────────────── │
│                                     │
│  Eye:    4 (Spontaneous)            │
│  Verbal: 5 (Oriented)              │
│  Motor:  6 (Obeys Commands)        │
│  ────────────────────               │
│  TOTAL: 15/15 — MILD               │  ← Color-coded by severity
│                                     │
│  AVPU Equivalent: ALERT             │
│                                     │
│  [Close]                            │
└─────────────────────────────────────┘
```

### Severity Color Coding
- **Green (13-15):** Mild
- **Yellow (9-12):** Moderate
- **Red (3-8):** Severe — additional warning banner:
  ```
  ⚠ GCS ≤8 — AIRWAY PROTECTION NEEDED
  ```

### Scoring Feedback
After the player submits their assessment, compare against the actual GCS values stored in `MedicalStateComponent`:
- If player's total matches actual ±1: "Your assessment matches the patient's neurological status"
- If player's total is off by >1: "Note: Actual GCS is [X] — reassess [component]"
- This teaches accurate GCS scoring

### Quick AVPU Option
Keep the existing quick AVPU check (`CHECK_CONSCIOUSNESS`) as-is. Add "GCS Assessment" as a separate, more detailed option below it in the Exam tab:
```
Primary Survey (ABCDE):
  [Check Airway] [Check Breathing] [Check Pulse] [Check Consciousness (AVPU)] [Check Bleeding]

Neurological:
  [GCS Assessment]  ← NEW, opens the 3-step guided flow
```

### Integration
- Add "GCS Assessment" button to Exam tab, in a "Neurological" subsection
- Opens as an overlay within the Exam tab content area
- Results also logged to telemetry via `assessment_performed` signal
- GCS result stored on patient metadata for debrief review

## Acceptance Criteria
- [x]3-step guided GCS assessment UI implemented (Eye → Verbal → Motor)
- [x]Each step shows descriptive labels for all response options
- [x]Running total displayed during assessment (E? + V? + M? format)
- [x]Final result shows all 3 components + total + severity + AVPU equivalent
- [x]Severity color-coded: green (13-15), yellow (9-12), red (3-8)
- [x]GCS ≤8 triggers prominent "AIRWAY PROTECTION NEEDED" warning
- [x]Player's GCS compared against actual values with feedback
- [x]Quick AVPU check remains unchanged alongside GCS option
- [x]Results logged to telemetry
- [x]GCS button placed in "Neurological" subsection of Exam tab

## Boundaries — Do NOT Touch
- Do not modify existing AVPU consciousness check
- Do not modify `GCSAssessment` backend logic (that's MON-14)
- Do not modify Patient/Stabilize/Differential tabs

## Notes
- Clinical reference: Medica Consultation Log #01, Part 2D
- GCS is the standard for tracking neurological status in EMS and hospital settings
- The guided 3-step approach mirrors how real clinicians perform GCS — component by component
