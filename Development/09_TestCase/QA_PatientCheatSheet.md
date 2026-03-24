# AeroMedica — Full QA Patient Cheat Sheet

> Generated 23-03-2026. Triage colors computed from `medical_state_component.gd:get_triage_priority()` algorithm.
> Use this during E2E testing to verify correct triage, diagnosis, and vital sign display.

---

## 1. Tutorial — Single Patient Response
**ID:** tutorial_01 | **Time:** Unlimited | **Patients:** 1

### Somchai (age 45)
| Field | Value |
|-------|-------|
| State | CONSCIOUS |
| Airway | CLEAR |
| Breathing | 20/min |
| Pulse | Present |
| Bleeding | 1 (minor) |
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

**Algorithm trace:** bleeding=1 < 2, conscious, SpO2=97 >= 90, breathing=20 (12-30 normal), mild_bleeding but BP=128 > 100, HR=92 not > 110, SpO2=97 > 95 → skip 228. HR=92 not > 100, not < 60, BP=128 > 90, SpO2=97 > 94 → skip 230.
**Triage: GREEN**
**Correct Diagnosis:** Minor Bleeding / Laceration, Soft Tissue Injury

---

## 2. Building Fire — Smoke Inhalation (Single Patient)
**ID:** building_fire_01 | **Time:** 540s (9 min) | **Patients:** 1

### Anong (age 38)
| Field | Value |
|-------|-------|
| State | CONSCIOUS |
| Airway | COMPROMISED |
| Breathing | 30/min |
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

**Algorithm trace:** airway=COMPROMISED (not "OBSTRUCTED" string match → skip line 215). bleeding=0 < 2, conscious, SpO2=88 < 90 → **RED at line 221**.
**Triage: RED**
**Correct Diagnosis:** Smoke Inhalation, Acute Respiratory Distress

---

## 3. Cardiac Arrest — Workplace Emergency
**ID:** cardiac_arrest_01 | **Time:** 480s (8 min) | **Patients:** 1

### Wichai (age 58)
| Field | Value |
|-------|-------|
| State | CARDIAC_ARREST |
| Airway | CLEAR |
| Breathing | 0/min |
| Pulse | Absent |
| Bleeding | 0 |
| HR | 0 bpm |
| BP | 0/0 mmHg |
| SpO2 | 0% |
| Pupils | 6/6 fixed |
| Skin | CYANOTIC / COOL / DIAPHORETIC |
| ECG | VENTRICULAR_FIBRILLATION |
| GCS | 3 (E1 V1 M1) |

**Algorithm trace:** CARDIAC_ARREST → **RED at line 209**. (Note: the game codes this as RED not BLACK. BLACK requires PatientState.DEAD.)
**Triage: RED**
**Correct Diagnosis:** Cardiac Arrest, Ventricular Fibrillation
**Critical:** CPR + AED within 60s

---

## 4. Cardiac Arrest — Sudden Collapse (Park)
**ID:** cardiac_arrest_01 | **Time:** 480s (8 min) | **Patients:** 1

### Prasert (age 62)
| Field | Value |
|-------|-------|
| State | CARDIAC_ARREST |
| Airway | OBSTRUCTED |
| Breathing | 0/min |
| Pulse | Absent |
| Pupils | 6/6 fixed |
| Skin | CYANOTIC / COOL / DIAPHORETIC |
| ECG | VENTRICULAR_FIBRILLATION |
| GCS | 3 (E1 V1 M1) |

**Triage: RED** (CARDIAC_ARREST at line 209)
**Correct Diagnosis:** Cardiac Arrest, Ventricular Fibrillation

---

## 5. Building Fire — Apartment Complex (3 Patients)
**ID:** building_fire_01 | **Time:** 720s (12 min) | **Patients:** 3 (+1 random)

### Niran (age 30)
| Field | Value |
|-------|-------|
| State | CONSCIOUS |
| Airway | CLEAR |
| Breathing | 28/min |
| Pulse | Present |
| Bleeding | 1 (minor) |
| HR | 110 bpm |
| BP | 135/85 mmHg |
| SpO2 | 93% |
| Temp | 37.4 C |
| BGL | 120 mg/dL |
| CRT | 2.0 sec |
| Pupils | 4/4 reactive |
| Skin | FLUSHED / HOT / DIAPHORETIC |
| ECG | SINUS_TACHYCARDIA |
| GCS | 15 (E4 V5 M6) |

**Algorithm trace:** bleeding=1 < 2, conscious, SpO2=93 >= 90, BP=135 > 70, HR=110 not > 150. Breathing=28 not > 30 not < 12. mild_bleeding=true, BP=135 > 100, HR=110 not > 110, SpO2=93 < 95 → **YELLOW at line 228** (mild bleeding + SpO2 < 95).
**Triage: YELLOW**

### Ploy (age 25)
| Field | Value |
|-------|-------|
| State | CONSCIOUS |
| Airway | OBSTRUCTED |
| Breathing | 10/min |
| Pulse | Present |
| Bleeding | 0 |
| HR | 125 bpm |
| BP | 100/65 mmHg |
| SpO2 | 82% |
| Pupils | 4/4 reactive |
| Skin | PALE / COOL / DIAPHORETIC |
| ECG | SINUS_TACHYCARDIA |
| GCS | 13 (E3 V4 M6) |
| CO Exposure | TRUE |

**Algorithm trace:** airway=OBSTRUCTED → **RED at line 215**.
**Triage: RED**

### Arthit (age 60)
| Field | Value |
|-------|-------|
| State | UNCONSCIOUS |
| Airway | OBSTRUCTED |
| Breathing | 4/min |
| Pulse | Present |
| Bleeding | 2 (severe) |
| HR | 130 bpm |
| BP | 80/50 mmHg |
| SpO2 | 75% |
| Pupils | 5/5 fixed |
| Skin | MOTTLED / HOT / DRY |
| ECG | SINUS_TACHYCARDIA |
| GCS | 4 (E1 V1 M2) |
| CO Exposure | TRUE |

**Algorithm trace:** breathing=4 < 8 → **RED at line 213**.
**Triage: RED**

### Suda (age 45) — RANDOM EVENT (spawns 180-300s)
| Field | Value |
|-------|-------|
| Bleeding | 2 (severe) |
| HR | 120 | BP | 95/60 | SpO2 | 90% |

**Triage: RED** (bleeding >= 2 at line 217)

**Correct Diagnosis (scenario):** Smoke Inhalation, 2nd-Degree Burns, Crush Injury

---

## 6. Mass Casualty — Market Explosion (6 Patients)
**ID:** mci_market_01 | **Time:** 1200s (20 min) | **Patients:** 6 (+1 random)

### Lek (age 22)
| HR | BP | SpO2 | Bleeding | Airway | Breathing | State |
|----|----|----|---------|--------|-----------|-------|
| 95 | 125/78 | 98% | 0 | CLEAR | 18 | CONSCIOUS |

**Triage: GREEN** (all normal)

### Malee (age 40)
| HR | BP | SpO2 | Bleeding | Airway | Breathing | State |
|----|----|----|---------|--------|-----------|-------|
| 115 | 95/60 | 94% | 2 | CLEAR | 24 | CONSCIOUS |

**Triage: RED** (bleeding >= 2 at line 217)

### Tawan (age 65)
| HR | BP | SpO2 | Bleeding | Airway | Breathing | State |
|----|----|----|---------|--------|-----------|-------|
| 55 | 85/50 | 80% | 1 | OBSTRUCTED | 8 | UNCONSCIOUS |

**Triage: RED** (airway OBSTRUCTED at line 215; also breathing=8 < 8 is false but UNCONSCIOUS at line 219)

### Kanda (age 33)
| HR | BP | SpO2 | Bleeding | Airway | Breathing | State |
|----|----|----|---------|--------|-----------|-------|
| 100 | 118/75 | 96% | 1 | CLEAR | 26 | CONSCIOUS |

**Algorithm trace:** bleeding=1 < 2, conscious, SpO2=96 >= 90, HR=100 not > 150. Breathing=26 (12-30 normal). mild_bleeding=true, BP=118 > 100, HR=100 not > 110, SpO2=96 > 95 → skip 228. BP=118 > 90, HR=100 not > 100 not < 60, SpO2=96 > 94 → skip 230.
**Triage: GREEN**

### Boonsri (age 70)
| HR | BP | SpO2 | Bleeding | Airway | Breathing | State |
|----|----|----|---------|--------|-----------|-------|
| 0 | 0/0 | 0% | 2 | OBSTRUCTED | 0 | CARDIAC_ARREST |

**Triage: RED** (CARDIAC_ARREST at line 209; transitions to BLACK when state becomes DEAD)

### Chai (age 48)
| HR | BP | SpO2 | Bleeding | Airway | Breathing | State |
|----|----|----|---------|--------|-----------|-------|
| 135 | 75/45 | 91% | 3 | CLEAR | 30 | CONSCIOUS |

**Algorithm trace:** bleeding=3 >= 2 → **RED at line 217**.
**Triage: RED**

### Anong (age 19) — RANDOM EVENT (spawns 300-480s)
| HR | BP | SpO2 | Bleeding | Airway | Breathing |
|----|----|----|---------|--------|-----------|
| 98 | 120/75 | 97% | 1 | CLEAR | 22 |

**Triage: GREEN** (all normal, mild bleeding only)

**Correct Diagnosis (scenario):** Blast Injury, Penetrating Trauma, Hemorrhagic Shock, Traumatic Cardiac Arrest

---

## 7. Road Traffic Accident — Intersection Collision (3 Patients)
**ID:** rta_intersection_01 | **Time:** 900s (15 min) | **Patients:** 3

### Somchai (age 35)
| HR | BP | SpO2 | Bleeding | Airway | Breathing | State |
|----|----|----|---------|--------|-----------|-------|
| 108 | 100/65 | 94% | 2 | CLEAR | 22 | CONSCIOUS |

**Algorithm trace:** bleeding=2 >= 2 → **RED at line 217**.
**Triage: RED**

### Nanthida (age 28)
| HR | BP | SpO2 | Bleeding | Airway | Breathing | State |
|----|----|----|---------|--------|-----------|-------|
| 122 | 108/72 | 88% | 1 | OBSTRUCTED | 28 | CONSCIOUS |

**Algorithm trace:** airway=OBSTRUCTED → **RED at line 215**.
**Triage: RED**

### Prasert (age 52)
| HR | BP | SpO2 | Bleeding | Airway | Breathing | State |
|----|----|----|---------|--------|-----------|-------|
| 135 | 72/40 | 85% | 3 | OBSTRUCTED | 6 | UNCONSCIOUS |

**Algorithm trace:** breathing=6 < 8 → **RED at line 213**.
**Triage: RED**

**Correct Diagnosis (scenario):** Blunt Thoracic Trauma, Cervical Spine Injury, Hemorrhagic Shock

---

## Quick Reference — Triage Summary

| Scenario | Patient | Triage |
|----------|---------|--------|
| Tutorial | Somchai | **GREEN** |
| Building Fire (1p) | Anong | **RED** |
| Cardiac (Workplace) | Wichai | **RED** |
| Cardiac (Park) | Prasert | **RED** |
| Building Fire (3p) | Niran | **YELLOW** |
| Building Fire (3p) | Ploy | **RED** |
| Building Fire (3p) | Arthit | **RED** |
| MCI | Lek | **GREEN** |
| MCI | Malee | **RED** |
| MCI | Tawan | **RED** |
| MCI | Kanda | **GREEN** |
| MCI | Boonsri | **RED** (→BLACK when DEAD) |
| MCI | Chai | **RED** |
| RTA | Somchai | **RED** |
| RTA | Nanthida | **RED** |
| RTA | Prasert | **RED** |

## Diagnosis Options (In-Game List)

The Differential tab presents ~40 diagnoses. For each scenario, match from:

| Scenario | Look For |
|----------|----------|
| Tutorial | Minor Bleeding / Laceration, Soft Tissue Injury |
| Building Fire (1p) | Smoke Inhalation, Upper Airway Obstruction |
| Cardiac | Cardiac Arrest, Ventricular Fibrillation |
| Building Fire (3p) | Smoke Inhalation, Burns (Thermal), Crush Injury / Rhabdomyolysis |
| MCI | Blast Injury, Penetrating Trauma, Haemorrhagic Shock, Cardiac Arrest |
| RTA | Trauma — Multi-system, Haemorrhagic Shock, Spinal Injury |

## ECG Strips (Missing)

The following ECG rhythms are referenced but image files may not exist yet:
- NORMAL_SINUS
- SINUS_TACHYCARDIA
- SINUS_BRADYCARDIA
- VENTRICULAR_FIBRILLATION
- ASYSTOLE

Chief Manager Martin will source these during Visual Polish pass.
