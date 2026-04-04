# AeroMedica -- QA Patient Cheat Sheet

> Updated 30-03-2026. 5 playable scenarios matching scenario select screen.
> Triage computed from medical_state_component.gd algorithm.

---

## 1. Tutorial -- Single Patient Response
**ID:** tutorial_01 | **Time:** Unlimited | **Difficulty:** 1/5 | **Patients:** 1

### Somchai (age 45)
| Field | Value |
|-------|-------|
| State | CONSCIOUS |
| Airway | CLEAR |
| Breathing | 20.0/min |
| Pulse | Present |
| Bleeding | 1 |
| HR | 92 bpm |
| BP | 128/82 mmHg |
| SpO2 | 97% |
| Temp | 36.8 C |
| BGL | 95 mg/dL |
| CRT | 2.0 sec |
| Pupils | 4/4 reactive |
| Skin | NORMAL / WARM / MOIST |
| ECG | SINUS_TACHYCARDIA |
| GCS | 14 (E4 V4 M6) |

**Triage: GREEN** (bleeding=1 but SpO2=97 >=95 and HR=92 <=110; HR not >100, not <60; BP=128 >=90; SpO2=97 >=95 -- all thresholds passed)
**Correct Diagnosis:** Minor Bleeding / Laceration, Soft Tissue Injury

---

## 2. Road Traffic Accident -- Intersection Collision
**ID:** rta_intersection_01 | **Time:** 900s (15 min) | **Difficulty:** 3/5 | **Patients:** 3

### Somchai (age 35)
| Field | Value |
|-------|-------|
| State | CONSCIOUS |
| Airway | CLEAR |
| Breathing | 22.0/min |
| Pulse | Present |
| Bleeding | 2 |
| HR | 108 bpm |
| BP | 100/65 mmHg |
| SpO2 | 94% |
| Temp | 36.9 C |
| BGL | 105 mg/dL |
| CRT | 2.8 sec |
| Pupils | 4/4 reactive |
| Skin | PALE / COOL / MOIST |
| ECG | SINUS_TACHYCARDIA |
| GCS | 15 (E4 V5 M6) |

**Triage: RED** (bleeding >= 2)
**Correct Diagnosis:** Trauma -- Multi-system, Haemorrhagic Shock, Internal Bleeding

### Nanthida (age 28)
| Field | Value |
|-------|-------|
| State | CONSCIOUS |
| Airway | OBSTRUCTED |
| Breathing | 28.0/min |
| Pulse | Present |
| Bleeding | 1 |
| HR | 122 bpm |
| BP | 108/72 mmHg |
| SpO2 | 88% |
| Temp | 37.1 C |
| BGL | 95 mg/dL |
| CRT | 2.2 sec |
| Pupils | 3/3 reactive |
| Skin | PALE / COOL / DIAPHORETIC |
| ECG | SINUS_TACHYCARDIA |
| GCS | 12 (E4 V3 M5) |

**Triage: RED** (airway OBSTRUCTED)
**Correct Diagnosis:** Tension Pneumothorax, Spinal Injury

### Prasert (age 52)
| Field | Value |
|-------|-------|
| State | UNCONSCIOUS |
| Airway | OBSTRUCTED |
| Breathing | 6.0/min |
| Pulse | Present |
| Bleeding | 3 |
| HR | 135 bpm |
| BP | 72/40 mmHg |
| SpO2 | 85% |
| Temp | 35.8 C |
| BGL | 90 mg/dL |
| CRT | 5.0 sec |
| Pupils | 6/7 fixed |
| Skin | PALE / COLD / DIAPHORETIC |
| ECG | SINUS_TACHYCARDIA |
| GCS | 4 (E1 V1 M2) |

**Triage: RED** (airway OBSTRUCTED; also breathing < 8, bleeding >= 2, UNCONSCIOUS, SpO2 < 90)
**Correct Diagnosis:** Head Injury / TBI, Haemorrhagic Shock, Internal Bleeding

---

## 3. Cardiac Arrest -- Workplace Emergency
**ID:** cardiac_arrest_01 | **Time:** 480s (8 min) | **Difficulty:** 2/5 | **Patients:** 1

### Wichai (age 58)
| Field | Value |
|-------|-------|
| State | CARDIAC_ARREST |
| Airway | CLEAR |
| Breathing | 0.0/min |
| Pulse | Absent |
| Bleeding | 0 |
| HR | 0 bpm |
| BP | 0/0 mmHg |
| SpO2 | 0% |
| Temp | 36.8 C |
| BGL | 180 mg/dL |
| CRT | 6.0 sec |
| Pupils | 6/6 fixed |
| Skin | CYANOTIC / COOL / DIAPHORETIC |
| ECG | VENTRICULAR_FIBRILLATION |
| GCS | 3 (E1 V1 M1) |

**Triage: RED** (CARDIAC_ARREST -- game codes as RED, not BLACK; BLACK requires PatientState.DEAD)
**Correct Diagnosis:** Cardiac Arrest, Ventricular Fibrillation

---

## 4. Mass Casualty -- Market Explosion
**ID:** mci_market_01 | **Time:** 1200s (20 min) | **Difficulty:** 5/5 | **Patients:** 6 (+1 random event)

### Lek (age 22)
| Field | Value |
|-------|-------|
| State | CONSCIOUS |
| Airway | CLEAR |
| Breathing | 18.0/min |
| Pulse | Present |
| Bleeding | 0 |
| HR | 95 bpm |
| BP | 125/78 mmHg |
| SpO2 | 98% |
| Temp | 36.9 C |
| BGL | 100 mg/dL |
| CRT | 1.5 sec |
| Pupils | 4/4 reactive |
| Skin | NORMAL / WARM / MOIST |
| ECG | NORMAL_SINUS |
| GCS | 15 (E4 V5 M6) |

**Triage: GREEN** (all values normal, no bleeding)
**Correct Diagnosis:** Blast Injury, Soft Tissue Injury

### Malee (age 40)
| Field | Value |
|-------|-------|
| State | CONSCIOUS |
| Airway | CLEAR |
| Breathing | 24.0/min |
| Pulse | Present |
| Bleeding | 2 |
| HR | 115 bpm |
| BP | 95/60 mmHg |
| SpO2 | 94% |
| Temp | 36.5 C |
| BGL | 110 mg/dL |
| CRT | 3.0 sec |
| Pupils | 4/4 reactive |
| Skin | PALE / COOL / DIAPHORETIC |
| ECG | SINUS_TACHYCARDIA |
| GCS | 14 (E4 V4 M6) |

**Triage: RED** (bleeding >= 2)
**Correct Diagnosis:** Penetrating Trauma, Haemorrhagic Shock

### Tawan (age 65)
| Field | Value |
|-------|-------|
| State | UNCONSCIOUS |
| Airway | OBSTRUCTED |
| Breathing | 8.0/min |
| Pulse | Present |
| Bleeding | 1 |
| HR | 55 bpm |
| BP | 85/50 mmHg |
| SpO2 | 80% |
| Temp | 36.0 C |
| BGL | 90 mg/dL |
| CRT | 4.0 sec |
| Pupils | 6/4 L-fixed R-reactive |
| Skin | PALE / COOL / DIAPHORETIC |
| ECG | SINUS_BRADYCARDIA |
| GCS | 4 (E1 V1 M2) |

**Triage: RED** (airway OBSTRUCTED; also UNCONSCIOUS, SpO2 < 90)
**Correct Diagnosis:** Head Injury / TBI, Blast Injury

### Kanda (age 33)
| Field | Value |
|-------|-------|
| State | CONSCIOUS |
| Airway | CLEAR |
| Breathing | 26.0/min |
| Pulse | Present |
| Bleeding | 1 |
| HR | 100 bpm |
| BP | 118/75 mmHg |
| SpO2 | 96% |
| Temp | 37.0 C |
| BGL | 105 mg/dL |
| CRT | 2.0 sec |
| Pupils | 4/4 reactive |
| Skin | NORMAL / WARM / MOIST |
| ECG | SINUS_TACHYCARDIA |
| GCS | 15 (E4 V5 M6) |

**Triage: GREEN** (bleeding=1 but SpO2=96 >=95 and HR=100 <=110; HR not >100, not <60; BP=118 >=90; SpO2=96 >=95)
**Correct Diagnosis:** Blast Injury, Soft Tissue Injury

### Boonsri (age 70)
| Field | Value |
|-------|-------|
| State | CARDIAC_ARREST |
| Airway | OBSTRUCTED |
| Breathing | 0.0/min |
| Pulse | Absent |
| Bleeding | 2 |
| HR | 0 bpm |
| BP | 0/0 mmHg |
| SpO2 | 0% |
| Temp | 35.5 C |
| BGL | 0 mg/dL |
| CRT | 6.0 sec |
| Pupils | 7/7 fixed |
| Skin | CYANOTIC / COLD / DRY |
| ECG | ASYSTOLE |
| GCS | 3 (E1 V1 M1) |

**Triage: RED** (CARDIAC_ARREST -- transitions to BLACK when state becomes DEAD)
**Correct Diagnosis:** Cardiac Arrest, Trauma -- Multi-system

### Chai (age 48)
| Field | Value |
|-------|-------|
| State | CONSCIOUS |
| Airway | CLEAR |
| Breathing | 30.0/min |
| Pulse | Present |
| Bleeding | 3 |
| HR | 135 bpm |
| BP | 75/45 mmHg |
| SpO2 | 91% |
| Temp | 35.8 C |
| BGL | 85 mg/dL |
| CRT | 4.5 sec |
| Pupils | 4/4 reactive |
| Skin | PALE / COLD / DIAPHORETIC |
| ECG | SINUS_TACHYCARDIA |
| GCS | 12 (E3 V4 M5) |

**Triage: RED** (bleeding >= 2)
**Correct Diagnosis:** Haemorrhagic Shock, Penetrating Trauma, Fracture -- Open

### Anong (age 19) -- RANDOM EVENT (spawns 300-480s)
| Field | Value |
|-------|-------|
| State | CONSCIOUS |
| Airway | CLEAR |
| Breathing | 22.0/min |
| Pulse | Present |
| Bleeding | 1 |
| HR | 98 bpm |
| BP | 120/75 mmHg |
| SpO2 | 97% |
| Temp | 36.9 C |
| BGL | 95 mg/dL |
| CRT | 2.0 sec |
| Pupils | 4/4 reactive |
| Skin | NORMAL / WARM / MOIST |
| ECG | SINUS_TACHYCARDIA |
| GCS | 15 (E4 V5 M6) |

**Triage: GREEN** (bleeding=1 but SpO2=97 >=95 and HR=98 <=110; all other thresholds passed)
**Correct Diagnosis:** Minor Bleeding / Laceration

---

## 5. Building Fire -- Smoke Inhalation
**ID:** building_fire_01 | **Time:** 540s (9 min) | **Difficulty:** 2/5 | **Patients:** 1

### Anong (age 38)
| Field | Value |
|-------|-------|
| State | CONSCIOUS |
| Airway | COMPROMISED |
| Breathing | 30.0/min |
| Pulse | Present |
| Bleeding | 0 |
| HR | 118 bpm |
| BP | 142/88 mmHg |
| SpO2 | 88% |
| Temp | 37.2 C |
| BGL | 130 mg/dL |
| CRT | 2.5 sec |
| Pupils | 4/4 reactive |
| Skin | FLUSHED / HOT / DIAPHORETIC |
| ECG | SINUS_TACHYCARDIA |
| GCS | 14 (E4 V4 M6) |
| CO Exposure | TRUE |

**Triage: RED** (SpO2 < 90; note: COMPROMISED is not OBSTRUCTED so airway rule does not trigger; breathing=30 is not >30 so breathing rule does not trigger; RED via SpO2=88 < 90)
**Correct Diagnosis:** Smoke Inhalation, Upper Airway Obstruction

---

## Quick Reference -- Triage Summary

| # | Scenario | Patient | Triage |
|---|----------|---------|--------|
| 1 | Tutorial | Somchai (45) | **GREEN** |
| 2 | RTA | Somchai (35) | **RED** |
| 2 | RTA | Nanthida (28) | **RED** |
| 2 | RTA | Prasert (52) | **RED** |
| 3 | Cardiac Arrest | Wichai (58) | **RED** |
| 4 | MCI | Lek (22) | **GREEN** |
| 4 | MCI | Malee (40) | **RED** |
| 4 | MCI | Tawan (65) | **RED** |
| 4 | MCI | Kanda (33) | **GREEN** |
| 4 | MCI | Boonsri (70) | **RED** (to BLACK when DEAD) |
| 4 | MCI | Chai (48) | **RED** |
| 4 | MCI | Anong (19) [random] | **GREEN** |
| 5 | Building Fire | Anong (38) | **RED** |

## Diagnosis Reference

| Scenario | Patient | Correct Diagnosis |
|----------|---------|------------------|
| Tutorial | Somchai (45) | Minor Bleeding / Laceration, Soft Tissue Injury |
| RTA | Somchai (35) | Trauma -- Multi-system, Haemorrhagic Shock, Internal Bleeding |
| RTA | Nanthida (28) | Tension Pneumothorax, Spinal Injury |
| RTA | Prasert (52) | Head Injury / TBI, Haemorrhagic Shock, Internal Bleeding |
| Cardiac Arrest | Wichai (58) | Cardiac Arrest, Ventricular Fibrillation |
| MCI | Lek (22) | Blast Injury, Soft Tissue Injury |
| MCI | Malee (40) | Penetrating Trauma, Haemorrhagic Shock |
| MCI | Tawan (65) | Head Injury / TBI, Blast Injury |
| MCI | Kanda (33) | Blast Injury, Soft Tissue Injury |
| MCI | Boonsri (70) | Cardiac Arrest, Trauma -- Multi-system |
| MCI | Chai (48) | Haemorrhagic Shock, Penetrating Trauma, Fracture -- Open |
| MCI | Anong (19) [random] | Minor Bleeding / Laceration |
| Building Fire | Anong (38) | Smoke Inhalation, Upper Airway Obstruction |

---

## Perfect Score Guide — Per Scenario

### Scoring Axes (weights)

| Axis | Weight | How to max it |
|------|--------|--------------|
| Triage Speed (20%) | First assessment within 15s, first triage within 60s (1 min) |
| Protocol Accuracy (25%) | Follow DRSABCDE in correct order, no skipped steps |
| Decision Quality (20%) | Triage correct color for each patient, prioritise RED patients first |
| Equipment Handling (15%) | Deploy correct equipment, no wrong equipment uses |
| Patient Outcome (20%) | Keep patients CONSCIOUS (100pts), avoid DEAD (0pts) |

Pass threshold: 60% per axis and 60% overall.

---

### 1. Tutorial — Perfect Score Walkthrough

**Time:** Unlimited | **Patients:** 1 (Somchai) | **Target triage:** GREEN

**Step-by-step:**
1. Walk to Somchai immediately (within 15s for max triage speed)
2. Open interaction panel (E key)
3. **Talk tab:** Ask about pain, history (SAMPLE/OPQRST) — builds communication score
4. **Examine tab — follow this exact order:**
   - D: Danger — check scene safety
   - R: Response — assess consciousness
   - S: Send for help — call for help
   - A: Airway — assess airway (result: CLEAR)
   - B: Breathing — assess breathing (result: 20/min, normal)
   - C: Circulation — assess pulse (result: Present)
   - D: Disability — check GCS (result: E4V4M6 = 14)
   - E: Exposure — Head-to-Toe exam (7 regions)
   - Deploy equipment: check Vital Signs (HR 92, BP 128/82, SpO2 97%)
   - Deploy ECG monitor (result: SINUS_TACHYCARDIA)
5. **Treat tab:**
   - Control bleeding (severity 1 — apply direct pressure/bandage)
   - No drugs needed for minor laceration
6. **Triage:** Assign GREEN (correct — stable, minor bleeding)
7. **Diagnose tab:** Select "Minor Bleeding / Laceration" + "Soft Tissue Injury"
8. Reassess patient once

**Key for perfect:** Do steps in DRSABCDE order. Do NOT skip any step. Assess within 15s of spawning.

---

### 2. RTA — Perfect Score Walkthrough

**Time:** 15 min | **Patients:** 3 | **All RED triage**

**Priority order (assess RED-first, sickest-first):**
1. **Prasert** (GCS 4, bilateral fixed pupils, breathing 6/min) — most critical
2. **Nanthida** (OBSTRUCTED airway, tracheal deviation, SpO2 88%) — airway emergency
3. **Somchai** (bleeding severity 2, but conscious GCS 15) — can wait briefly

**For each patient, follow protocol sequence:**

**Prasert (first — within 15s):**
1. Scene safety check
2. Assess consciousness (UNCONSCIOUS)
3. Assess airway (OBSTRUCTED) -> Jaw thrust (NOT head tilt — suspected spinal injury)
4. Assess breathing (6/min — critical) -> Deploy Bag Valve Mask
5. Assess pulse (Present but weak)
6. Control bleeding (severity 3)
7. Triage: RED
8. DDx: Head Injury / TBI, Haemorrhagic Shock, Internal Bleeding

**Nanthida (second):**
1. Scene safety, assess consciousness (CONSCIOUS but confused)
2. Assess airway (OBSTRUCTED) -> Head tilt chin lift
3. Assess breathing (28/min)
4. Assess pulse (Present)
5. Control bleeding (severity 1)
6. Triage: RED
7. DDx: Tension Pneumothorax, Spinal Injury

**Somchai (third):**
1. Scene safety, assess consciousness (CONSCIOUS)
2. Assess airway (CLEAR)
3. Assess breathing (22/min)
4. Assess pulse (Present)
5. Control bleeding (severity 2 — arterial leg laceration, apply tourniquet)
6. Triage: RED
7. DDx: Trauma -- Multi-system, Haemorrhagic Shock, Internal Bleeding

**Key for perfect:** Prioritise Prasert first (sickest). Use jaw thrust not head tilt on suspected spinal. All 3 patients are RED. Complete all within 15 minutes.

---

### 3. Cardiac Arrest — Perfect Score Walkthrough

**Time:** 8 min | **Patients:** 1 (Wichai) | **Target triage:** RED

**Step-by-step (speed is critical):**
1. Run to Wichai immediately (within 15s)
2. Scene safety check
3. Assess consciousness (CARDIAC_ARREST — unresponsive)
4. Call for help
5. Assess airway (CLEAR)
6. Assess breathing (0/min — not breathing)
7. Assess pulse (ABSENT)
8. **Start CPR immediately** (gated — must assess pulse first)
9. **Deploy AED** -> AED auto-checks rhythm (VENTRICULAR_FIBRILLATION = shockable)
10. Deliver shock -> rhythm may convert to Normal Sinus (ROSC logic)
11. Reassess after shock
12. Triage: RED
13. DDx: Cardiac Arrest, Ventricular Fibrillation

**Key for perfect:** Speed is everything. Start CPR within 60s of arrival (passing criteria in JSON). AED before 2 minutes. Follow exact DRSABCDE->CPR->AED order. Do NOT skip pulse check before CPR.

---

### 4. MCI — Perfect Score Walkthrough

**Time:** 20 min | **Patients:** 6 (+1 random) | **START Triage mass casualty**

**Priority order (triage RED patients first, GREEN last):**
1. **Boonsri** (70, CARDIAC_ARREST, asystole) -> Triage RED (Note: in MCI context, injuries incompatible with survival — BLACK when dead. But initial triage is RED)
2. **Tawan** (65, UNCONSCIOUS, OBSTRUCTED airway, GCS 4) -> RED
3. **Malee** (40, bleeding severity 2, hypotensive) -> RED
4. **Chai** (48, bleeding severity 3, open femur fracture) -> RED
5. **Kanda** (33, mild bleeding, stable) -> GREEN
6. **Lek** (22, no bleeding, fully stable) -> GREEN
7. **Anong** (19, random event 300-480s, mild) -> GREEN when appears

**For each patient — use START Triage rapid protocol:**
1. Assess consciousness
2. Assess airway (open if needed)
3. Assess breathing
4. Assess pulse
5. Control bleeding if present
6. Assign triage tag immediately

**DDx per patient:**
- Lek: Blast Injury, Soft Tissue Injury
- Malee: Penetrating Trauma, Haemorrhagic Shock
- Tawan: Head Injury / TBI, Blast Injury
- Kanda: Blast Injury, Soft Tissue Injury
- Boonsri: Cardiac Arrest, Trauma -- Multi-system
- Chai: Haemorrhagic Shock, Penetrating Trauma, Fracture -- Open
- Anong (random): Minor Bleeding / Laceration

**Key for perfect:** Speed over depth — in MCI, rapid triage all patients before deep assessment. Get to every patient. Triage tags assigned within 30s each. Do NOT spend 5 minutes on one patient while others deteriorate. Prioritise RED patients for treatment after all are triaged. Watch for Anong spawning at 300-480s.

---

### 5. Building Fire — Perfect Score Walkthrough

**Time:** 9 min | **Patients:** 1 (Anong) | **Target triage:** RED | **Hazard: FIRE zones**

**DANGER: 3 fire zones with damage. Stay out of orange circles. 15s in fire = EMT incapacitated.**

**Step-by-step:**
1. Spawn in staging area (safe zone)
2. **Avoid fire zones** (FireSpawnSmoke 1-3 have damage circles)
3. Locate Anong — navigate around fire, not through it
4. Scene safety check
5. Assess consciousness (CONSCIOUS)
6. Call for help
7. Assess airway (COMPROMISED — not obstructed, but stridor + soot)
8. Open airway maneuver
9. Assess breathing (30/min — borderline high)
10. Deploy oxygen mask (critical — SpO2 88%, CO exposure)
11. Assess pulse (Present)
12. Check vitals: HR 118, SpO2 88%, Temp 37.2
13. Triage: RED (SpO2 < 90)
14. DDx: Smoke Inhalation, Upper Airway Obstruction
15. Reassess after oxygen

**Key for perfect:** Do NOT walk into fire circles. Route around hazards. Deploy oxygen mask early — SpO2 88% is critical. Follow DRSABCDE exactly. Airway management is the priority (COMPROMISED with CO exposure). Complete within 9 minutes.

---

### General Tips for All Scenarios

1. **First 15 seconds matter** — walk to the nearest/sickest patient immediately for max Triage Speed score
2. **Follow DRSABCDE order** — skipping steps or doing them out of order costs Protocol Accuracy points
3. **Triage before treatment in MCI** — tag everyone first, treat RED patients after
4. **Deploy equipment before reading vitals** — you cannot see Vital Signs values without deploying the monitoring equipment first
5. **Cooldown awareness** — DRS buttons have 0.5s cooldown, ABCDE has 2s. Actions queue if you click during cooldown
6. **Use the Talk panel** — asking the patient questions builds your assessment context and helps with DDx
7. **Check ECG** — deploy the monitor, then use "Identify Rhythm" button. Important for Cardiac Arrest (VFib) and Bradycardia scenarios
8. **Submit DDx for each patient** — per-patient diagnosis is now scored individually, not per-scenario
9. **Watch deterioration** — unfocused patients deteriorate at 0.3x rate, but they still deteriorate. Return to check on them
10. **Avoid hazards** — fire zones deal damage. 15 seconds = incapacitated. Route around, not through
