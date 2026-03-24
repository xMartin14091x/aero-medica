# OVR-05 — Medica Feature Integration Testing

**Phase:** Phase 6 — Drug Administration & Medical Bag Expansion
**Team:** Overseer — HQ/Management
**Status:** `[x] Complete`
**Depends on:** All Phase 4, 5, 6 tickets
**Blocks:** None

---

## Scope
Comprehensive integration testing of all Medica-recommended features: OPQRST, vital signs, ECG, GCS, secondary survey, drug administration, and medical bag tiers. Verify end-to-end gameplay flow with the expanded assessment and treatment systems.

## Test Scenarios

### Test 1: OPQRST Integration
- Open PatientInteractionUI on a conscious patient with pain
- Navigate to Patient tab → OPQRST category
- Ask all 6 OPQRST questions
- Verify responses match scenario JSON data
- Verify OPQRST is greyed out for unresponsive patients
- Verify auto-suggest hint appears for patients with pain

### Test 2: Vital Signs Assessment
- Open Exam tab on a patient
- Verify 8 new vital sign buttons visible in "Vital Signs" section
- Perform heart rate check (no equipment needed) — verify HR reading
- Attempt SpO2 check WITHOUT pulse oximeter — verify "Requires: Pulse Oximeter" error
- Deploy pulse oximeter from medical bag
- Retry SpO2 check — verify reading with color-coded display
- Repeat for BP cuff, penlight, glucometer, thermometer
- Verify normal ranges color-coding: green/yellow/red

### Test 3: ECG / Cardiac Monitor
- Load cardiac arrest scenario (VF rhythm)
- Attach AED to patient
- Verify AED mode: rhythm image displayed, "Shock Advised" shown, no identification required
- Load a new scenario with sinus tachycardia
- Attach cardiac monitor
- Verify manual mode: rhythm image displayed, HR shown, rhythm name hidden
- Select correct rhythm from identification buttons — verify "Correct" feedback
- Select incorrect rhythm — verify "Incorrect" feedback, retry allowed
- Verify placeholder images load correctly from `assets/textures/ecg/`

### Test 4: GCS Assessment
- Open Exam tab → Neurological section → "GCS Assessment"
- Walk through 3-step guided assessment (Eye → Verbal → Motor)
- Verify running total updates at each step
- Verify final score with severity classification and AVPU equivalent
- Test GCS ≤8 patient — verify "AIRWAY PROTECTION NEEDED" warning
- Verify existing AVPU check still works independently

### Test 5: Secondary Survey
- Complete primary survey (ABCDE) on a patient
- Verify secondary survey section unlocks after primary survey completion
- Examine all 7 body regions
- Verify findings text matches scenario JSON data
- Verify completion tracking (X/7 regions)
- Verify critical findings show alert prompts
- Verify secondary survey greyed out before primary survey completion

### Test 6: Drug Administration
- Open Stabilize tab → Medications section
- Select drug (Epinephrine 1:10,000)
- Verify dose options and valid routes display correctly
- Attempt IV administration WITHOUT IV access — verify error message
- Start IV on patient
- Retry drug administration — verify success feedback
- Verify administration log entry with timestamp
- Test max dose enforcement (administer until limit)
- Test repeat interval enforcement (administer too soon)
- Verify Epinephrine 1:1,000 is separate entry with IM-only route

### Test 7: Medical Bag Tiers
- Load BLS scenario — verify only BLS items in bag
- Load ALS scenario — verify BLS + ALS items in bag
- Deploy diagnostic tool (pulse ox) — verify enables gated assessment
- Use consumable (bandage) — verify quantity decreases
- Deplete consumable — verify greyed out with "Depleted"
- Verify category tabs filter correctly

### Test 8: Full Gameplay Loop (End-to-End)
- Start RTA scenario (3 patients, BLS bag)
- Walk to Patient 1 (alert, bleeding):
  1. Primary survey (ABCDE) — all vital signs
  2. SAMPLE + OPQRST history
  3. Secondary survey — find all injuries
  4. Stabilize — apply treatment from bag
  5. Triage tag
- Walk to Patient 2 (verbal, obstructed airway):
  1. Primary survey — GCS assessment
  2. Airway management
  3. Vital signs monitoring
- Walk to Patient 3 (unresponsive, cardiac arrest):
  1. CPR + AED (ECG displayed)
  2. Drug administration (epinephrine)
  3. Verify OPQRST greyed out (unresponsive)
- Complete scenario → verify debrief includes:
  - Vital sign readings
  - GCS scores
  - Drug administration log
  - Medication errors (if any)
  - Secondary survey completeness

## Acceptance Criteria
- [x]All 8 test scenarios pass
- [x]No regression in existing Phase 0-3 functionality
- [x]Equipment-gating works correctly across all gated assessments
- [x]ECG placeholder images load and display correctly
- [x]Drug errors tracked and visible in debrief
- [x]Medical bag tier correctly filters items by scenario
- [x]All new signals properly connected between managers and UI
- [x]Telemetry captures all new action types
- [x]Performance: no frame drops with expanded assessment data

## Notes
- This is the final integration gate for the Medica feature set
- All clinical accuracy must be verified against Medica Consultation Log #01
- Medica may be consulted for any clinical accuracy questions during testing
