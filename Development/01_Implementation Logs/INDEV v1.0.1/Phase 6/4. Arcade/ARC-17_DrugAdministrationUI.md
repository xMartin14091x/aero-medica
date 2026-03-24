# ARC-17 — Drug Administration UI

**Phase:** Phase 6 — Drug Administration & Medical Bag Expansion
**Team:** Arcade — Frontend/Creative
**Status:** `[x] Complete`
**Depends on:** MON-16 (drug administration system)
**Blocks:** None

---

## Scope
Create the drug administration interface within the Stabilize tab of `PatientInteractionUI`. Player selects drug, dose, and route, then administers with feedback. Track and display medication errors for learning.

## Implementation Detail

### Drug Administration Panel
Add a "Medications" section to the Stabilize tab (alongside existing equipment application):

```
┌──────────────────────────────────────────────┐
│  STABILIZE                                   │
│ ──────────────────────────────────────────── │
│                                              │
│  Equipment:                                  │
│  [Apply Bandage] [Apply Tourniquet] [...]     │  ← existing
│                                              │
│  ──────────────────────────────────────────  │
│                                              │
│  Medications:                          [NEW] │
│  ┌────────────────────────────────────────┐  │
│  │  Drug: [Epinephrine (1:10,000)    ▼]  │  │  ← Dropdown/list
│  │  Dose: [1 mg                      ▼]  │  │  ← Dose selection
│  │  Route: [IV ○] [IO ○] [IM ○] [IN ○]  │  │  ← Route radio buttons
│  │                                        │  │
│  │  Indication: Cardiac arrest            │  │  ← Auto-shown from drug data
│  │  ⚠ 1:10,000 for IV — NOT 1:1,000     │  │  ← Concentration warning
│  │                                        │  │
│  │  [Administer Drug]                     │  │
│  └────────────────────────────────────────┘  │
│                                              │
│  Administration Log:                         │
│  • Epinephrine 1mg IV — 02:15 ✓             │
│  • Amiodarone 300mg IV — 04:30 ✓            │
│  • Naloxone 0.4mg IV — ERROR: No IV access  │
│                                              │
└──────────────────────────────────────────────┘
```

### Drug Selection List
- Show drugs available in the current bag tier (BLS or ALS)
- Group by category: Cardiac, Pain, Antidotes, Fluids, Seizure
- Each drug shows name and brief indication
- Selected drug populates dose options and valid routes automatically

### Dose and Route Selection
- **Dose:** Dropdown populated from `dose_options` in drug JSON
- **Route:** Radio buttons showing only valid routes for the selected drug
- Invalid routes greyed out with tooltip explanation

### Indication and Warning Display
When a drug is selected:
- Show `indication` text below the drug name
- Show `concentration_warning` if present (e.g., epinephrine distinction)
- Show `clinical_note` if present (e.g., naloxone titration warning)
- Show `contraindications` if any match the patient's current state

### Administration Feedback
After clicking "Administer Drug":
- **Success:** Green flash, log entry with ✓, brief effect description
- **Error:** Red flash, log entry with error type, explanation text:
  - "No IV access — start an IV first"
  - "Contraindicated: patient has active bleeding"
  - "Maximum doses reached (3/3)"
  - "Too soon — wait [X] seconds before next dose"
- **Wrong drug for condition:** Yellow warning in log — scored in debrief but not blocked (player learns from mistakes)

### Administration Log
Scrollable log showing all drugs administered in this session:
- Timestamp (scenario elapsed time)
- Drug name, dose, route
- Status icon: ✓ (success), ✗ (error), ⚠ (warning)
- This log feeds into the debrief/scoring system

### Concentration Distinction
For epinephrine specifically:
- Show "1:10,000" and "1:1,000" as SEPARATE entries in the drug list
- Do NOT allow the player to select IV route for 1:1,000 (only IM)
- Do NOT allow the player to select IM route for 1:10,000 (only IV/IO)
- This teaches the real-world concentration distinction

## Acceptance Criteria
- [x]Drug selection list shows available drugs filtered by bag tier
- [x]Dose dropdown populated from drug data
- [x]Route radio buttons show only valid routes per drug
- [x]Indication and clinical warnings displayed for selected drug
- [x]Administration feedback with success/error/warning states
- [x]Scrollable administration log with timestamps
- [x]Epinephrine 1:1,000 and 1:10,000 shown as separate entries
- [x]Contraindication warnings displayed before administration
- [x]IV/IO drugs blocked without vascular access (clear error message)
- [x]Medication errors logged for debrief scoring

## Boundaries — Do NOT Touch
- Do not modify `DrugAdministrationManager` (that's MON-16)
- Do not modify existing equipment application in Stabilize tab
- Do not modify Patient/Exam/Differential tabs

## Notes
- Clinical reference: Medica Consultation Log #01, Part 4
- Key UX principle: let the player make mistakes — the debrief is where learning happens
- Concentration distinction for epinephrine is a critical teaching moment per Medica's recommendation
