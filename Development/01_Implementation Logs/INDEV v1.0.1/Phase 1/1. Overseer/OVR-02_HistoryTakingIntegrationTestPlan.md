# OVR-02 — History Taking Integration Test Plan

**Phase:** Phase 1 — Patient History Taking
**Team:** Overseer — HQ/Management
**Status:** `[x] Complete`
**Depends on:** MON-03, MON-04, ARC-02, ARC-03, ARC-04
**Blocks:** None

---

## Scope

Define and execute the end-to-end integration test plan for the patient history taking system. Verify the full flow from player interaction through data retrieval to UI display.

## Test Scenarios

### Test 1 — Basic History Flow (Tutorial Level)
1. Load tutorial scenario
2. Walk to conscious patient, press E
3. History dialogue panel opens with patient name
4. Select "S — Symptoms" category
5. Select "What happened?" question
6. Verify: response appears with typewriter animation
7. Verify: question is now greyed out with checkmark
8. Select another question from same category
9. Press Back, select different category
10. Close dialogue (ESC)
11. Verify: re-opening shows previously asked questions as checked

### Test 2 — Unconscious Patient
1. Load scenario with unconscious patient (or wait for deterioration)
2. Walk to unconscious patient, press E
3. Select any SAMPLE category and question
4. Verify: "Patient is unresponsive." appears in grey italic
5. Verify: all categories return unresponsive for this patient

### Test 3 — Multiple Patients
1. Load MCI scenario (multiple patients)
2. Take history from Patient A (ask 2-3 questions)
3. Walk to Patient B, take history
4. Return to Patient A
5. Verify: Patient A's previously asked questions are still marked as asked
6. Verify: conversation log shows Patient A's previous exchanges

### Test 4 — History → Assessment Transition
1. Take history from a patient
2. Close history dialogue
3. Interact with same patient again
4. Verify: player can now enter assessment mode (or re-enter history)

### Test 5 — Equipment Interaction Priority
1. Pick up equipment (e.g., bandage)
2. Walk to patient, press E
3. Verify: equipment use takes priority over history taking
4. Drop equipment, interact again
5. Verify: history taking mode activates

## Acceptance Criteria

- [x] All 5 test scenarios pass
- [x] No crashes or null reference errors during any flow
- [x] UI elements display correctly and don't overlap
- [x] Typewriter animation completes without visual artifacts
- [x] Performance is acceptable (no frame drops during dialogue)

## Notes

This ticket runs AFTER all other Phase 1 tickets are complete. The Verification Scholar signs off on all test results before filing the OverseerReport.
