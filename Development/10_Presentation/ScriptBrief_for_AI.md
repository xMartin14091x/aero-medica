# AeroMedica — Script Creation Brief

**Purpose:** This document provides all information needed for an AI to generate a 10-minute pitch script for AeroMedica: Protocol Playground at the Thailand Metaverse Hackathon and Exhibition 2026 Final Round.

**Language:** Thai (with English technical terms kept as-is where natural in Thai speech, e.g., "DRSABCDE", "START Triage", "Ollama", "JSON")

**Tone:** Professional but passionate. This is a medical training tool, not entertainment. Speak with conviction — you believe this can save lives. Avoid hype words. Be specific with numbers.

**Speaker:** A university student presenting their hackathon project to a panel of judges.

**Total Time:** 10 minutes (strict)

---

## CONTEXT: What Is This Project?

AeroMedica: Protocol Playground is a 3D isometric offline EMT (Emergency Medical Technician) training simulation. Players take the role of an EMT responding to emergency scenes — they must assess patients using real medical protocols (DRSABCDE), measure vital signs, read ECG, perform CPR + AED, administer drugs, triage patients using START Triage (GREEN/YELLOW/RED/BLACK), and diagnose from 47 conditions.

The AI system uses Ollama (llama3.1:8b) running locally — no internet needed. AI plays two roles: it acts as the patient (answering questions naturally based on the patient's medical data), and it reviews the player's performance after each scenario with detailed feedback. If the machine can't run AI, the game automatically falls back to 70 pre-written cached reviews (7 scenarios x 5 performance tiers x 2 languages).

Built with Godot 4.6 in 25 days (86 development sessions). Bilingual Thai/English. Open source on GitHub and downloadable on Google Drive.

**Team:** Ollama Paramedic
**Competition:** Thailand Metaverse Hackathon and Exhibition 2026 — Final Round
**Track:** การแพทย์ (Medical)
**Event Date:** April 4, 2026

---

## THE 15 SLIDES (in order)

Below is a description of each slide's visual content. The script must match these slides in order.

### Slide 1 — Title
**Visual:** Large title "AeroMedica: Protocol Playground". Subtitle: "ระบบจำลองการฝึกอบรม 3 มิติสำหรับบุคลากรการแพทย์ฉุกเฉิน (EMT 3D Training Simulator)". Team name: Ollama Paramedic. Event: TMH 2026.
**Script guidance:** Brief greeting, introduce team and project name. One-sentence description. Keep under 15 seconds.

### Slide 2 — The Skill Decay Crisis (วิกฤตการถดถอยของทักษะ)
**Visual:** Survival curve graph showing skill retention dropping from 100% to 14% at 12 months, then to 0% at 24 months. Two stat callouts: "[-86%] ACLS pass rate drops to 14% in 12 months (Smith et al., 2008)" and "[-61%] Clinical skills degrade 61% in 2 years (Stept & Stross, 1980)". Bottom text: rare critical skills are lost fastest, traditional re-training is expensive and limited by location.
**Script guidance:** This is the problem statement. Cite both research sources by name. Explain why this matters — trained personnel lose critical skills before they need them. Traditional drills are expensive, infrequent, and non-repeatable. Build urgency. 45-60 seconds.

### Slide 3 — The Missing Link (เครื่องมือเสริมเพื่ออุดช่องโหว่การฝึกฝน)
**Visual:** Left: hospital bed illustration (expensive simulation lab). Arrow labeled "SUPPLEMENT, NOT REPLACE" pointing to right: laptop illustration (self-practice, free, anywhere). Three feature boxes: [100% OFFLINE], [AI TELEMETRY] — auto-assessment without instructor, [ZERO RISK] — safe skill review to supplement real training.
**Script guidance:** Position AeroMedica as the bridge. Emphasize "supplement, not replace" — this is NOT trying to replace real training, it's filling the gap between training sessions. Highlight the three key differentiators: offline, AI-powered auto-assessment, zero risk to real patients. 30-40 seconds.

### Slide 4 — The Gameplay Loop (ภายใต้แรงกดดันของเวลา)
**Visual:** Circular flow: 1. SPAWN (enter 3D scenario) → 2. APPROACH (reach patient quickly) → 3. ASSESS & TREAT (assess and treat) → 4. AI FEEDBACK (receive real-time analysis). Center: timer showing 08:45 with a health bar. Text: patients deteriorate in real-time.
**Script guidance:** Describe the core gameplay loop briefly. Emphasize the time pressure — patients deteriorate from CONSCIOUS → UNCONSCIOUS → CARDIAC_ARREST → DEAD if not treated. This creates real decision-making pressure like actual emergencies. 30-40 seconds.

### Slide 5 — Four Panels, One Patient (4 แผงควบคุม, 1 ผู้ป่วย)
**Visual:** Four quadrants showing the 4 UI tabs: TALK (AI-powered patient dialogue via Ollama — exclusive feature), EXAMINE (8-step DRSABCDE + 8 vital signs + 7 ECG rhythms + GCS), TREAT (ACLS/BLS medical bag + CPR + AED with ROSC logic + drug dosing), DIAGNOSE (47 conditions across 6 clinical categories + per-patient verified DDx).
**Script guidance:** Walk through each panel briefly. Emphasize that TALK is the exclusive feature — AI patient dialogue that no other training simulation has. For EXAMINE, mention the 8 DRSABCDE steps, 8 vital signs (must deploy equipment first), ECG with 7 rhythms, GCS scoring. For TREAT, mention BLS/ALS medical bag tiers, CPR gated behind pulse assessment, AED with shockable rhythm detection, ROSC logic. For DIAGNOSE, mention 47 conditions across 6 categories, each patient has a verified correct diagnosis. 50-60 seconds.

### Slide 6 — Built on Real Protocols (ความแม่นยำทางการแพทย์ตามโปรโตคอลจริง)
**Visual:** Four verification badges: Clinical Verification for DRSABCDE, START Triage, ACLS/BLS, GCS Scoring. Case study box showing RTA scenario (3 patients, different injuries). Human body diagram with callouts: HEAD INJURY GCS: 8, CHEST TRAUMA SpO2: 90%, LEG FRACTURE BP: 100/50. Bottom: "Algorithms and drug dosages reference international EMS standards."
**Script guidance:** This is the credibility slide. Emphasize that all medical data is clinically verified — vital signs match triage categories, drug dosages follow ACLS 2020 guidelines, DDx matches actual presenting symptoms (not random). Use the RTA case study to show that each patient has unique injuries based on real clinical presentations. 40-50 seconds.

### Slide 7 — The Escalation Matrix (ระดับความรุนแรงของสถานการณ์)
**Visual:** Left: difficulty progression — [1/5] Tutorial (1 patient, unlimited time), [2/5] RTA (3 patients, 10 min), [3/5] Cardiac Arrest (1 patient, 5 min), [4/5] Building Fire (3 patients, 8 min, hazard zones), [5/5] MCI Mass Casualty (6+1 patients, 15 min, highest difficulty). Right: Clinical Timeline flowchart CONSCIOUS → UNCONSCIOUS → CARDIAC_ARREST → DEAD.
**Script guidance:** Walk through the difficulty progression. Each scenario adds complexity: Tutorial teaches the system, RTA adds multi-patient triage, Cardiac adds CPR/AED under time pressure, Building Fire adds environmental hazards (fire damages the EMT — 15 seconds in fire = incapacitated), MCI is the ultimate test (6 patients + 1 random event patient arriving mid-scenario, limited equipment, must use START Triage under extreme pressure). 50-60 seconds.

**IMPORTANT — Correct values for slide 7:**
| Scenario | Patients | Time | Difficulty |
|----------|----------|------|-----------|
| Tutorial | 1 | Unlimited | 1/5 |
| Road Traffic Accident | 3 | 10 min | 2/5 |
| Cardiac Arrest | 1 | 5 min | 3/5 |
| Building Fire | 3 | 8 min | 4/5 |
| Mass Casualty Incident | 6+1 random | 15 min | 5/5 |

### Slide 8 — Privacy by Design, 100% Offline (ความเป็นส่วนตัวตั้งแต่การออกแบบ)
**Visual:** Architecture diagram. Center box: LOCAL DEVICE — "patient data never leaves the machine". Game Engine → AI Engine (Ollama llama3.1:8b — processes dialogue and analysis). Right: Internet/External Server with large red X (no connection). Bottom: Offline Cache — 70 cached reviews (7 scenarios, 5 performance tiers, 2 languages) guaranteeing gameplay even without AI.
**Script guidance:** Explain the privacy architecture. All data stays on the local machine — no cloud, no external server, no student data leaving the building. This is critical for educational institutions with data privacy policies. The AI runs locally via Ollama. If the machine can't run AI, the cached fallback system has 70 pre-written reviews covering every scenario and performance level in both Thai and English. The game always works regardless of hardware. 40-50 seconds.

### Slide 9 — Measure, Track, Improve (วัดผล, ติดตาม, พัฒนา)
**Visual:** Left: 5-axis radar chart — Triage Speed (ความเร็วในการคัดกรอง), Protocol Accuracy (ความถูกต้องของโปรโตคอล), Decision Quality (คุณภาพการตัดสินใจ), Equipment Handling (การใช้อุปกรณ์), Patient Outcome (ผลลัพธ์ของผู้ป่วย). Right: line graph showing improvement over time. Two boxes: [SILENT TELEMETRY] — automatic scoring the moment a scenario ends, [DATA EXPORT] — CSV/JSON export for instructors.
**Script guidance:** Explain the 5-axis scoring system. Briefly describe what each axis measures: Triage Speed (first triage under 60 seconds = full marks), Protocol Accuracy (action sequence compared to correct DRSABCDE protocol), Decision Quality (correct triage tag + correct diagnosis), Equipment Handling (appropriate equipment for condition), Patient Outcome (final vs initial patient state). The dashboard tracks progress over time with trend graphs. Data can be exported as CSV or JSON for institutional analysis. 40-50 seconds.

### Slide 10 — The Paradigm Shift Matrix (การเปลี่ยนกระบวนทัศน์)
**Visual:** 3-row comparison table. Traditional Training vs AeroMedica. Realism: static textbooks + limited mannequins vs interactive 3D + AI patient conversation. Assessment: requires instructor + scheduling vs AI instant analysis + 5-axis scoring. Access: must travel to training center + venue costs vs runs offline anywhere + no cost per session.
**Script guidance:** Quick comparison — don't linger, the visual speaks for itself. Emphasize the three shifts: from passive to active learning, from instructor-dependent to AI-automated assessment, from location-bound to anywhere-accessible. 20-30 seconds.

### Slide 11 — The Open Source Stack (เทคโนโลยี Open Source ไร้ค่าลิขสิทธิ์)
**Visual:** Diamond layout: ENGINE — Godot 4.6 (no licensing fees), AI — Ollama (free local AI), DATA — JSON/CSV (300+ keys, Thai/English), ASSETS — Kenney CC0 (100% free), VERSION — Git + GitHub. Bottom banner: [ETHICAL AI] AI tool usage (Claude Code + Gemini) disclosed transparently in CONTRIBUTION.md.
**Script guidance:** Briefly list the stack — everything is open source and free. Godot has no licensing fees, Ollama is free, Kenney assets are CC0, data format is open JSON/CSV. Mention the ethical AI disclosure — all AI tools used in development are documented in CONTRIBUTION.md. Transparency is important. 20-30 seconds.

### Slide 12 — The B2B Ecosystem (ระบบนิเวศ B2B)
**Visual:** Three columns: HOSPITALS (ER staff skill review at workplace, reduce mannequin/instructor costs), INSTITUTIONS (supplementary tool for practical learning), MEDICAL SCHOOLS (unlimited student practice, break scheduling bottleneck). Bottom banner: [IMPACT] reduce massive costs + expand training access nationwide without risk to real patients.
**Script guidance:** Describe the B2B target. Three customer segments: hospitals can use it for ER staff skill maintenance, EMT training institutions get a supplementary practice tool, medical schools can let students practice unlimited times without scheduling constraints. The impact: reduce costs, expand access, zero risk to real patients. 30-40 seconds.

### Slide 13 — Instructor Web Dashboard (Future)
**Visual:** Left: 3 laptop game clients (students practicing on local network). Center: server (FastAPI + SQLite + WebSocket — real-time data). Right: LAN Dashboard monitor (instructor monitors entire class in real-time). Bottom: OFFLINE QUEUE — data stored locally if network drops, auto-syncs when reconnected. 8 implementation tickets planned and approved.
**Script guidance:** This is the future roadmap slide. Describe the planned Instructor Web Dashboard: instructors open a browser on any device on the same LAN and see which student is playing which scenario, live scores, and struggle alerts — without walking to every machine. If the network drops, telemetry queues locally and syncs when reconnected. The plan has 8 tickets written and approved, ready to implement. 30-40 seconds.

### Slide 14 — Traction & Vision (ผลลัพธ์และวิสัยทัศน์)
**Visual:** Three large stat numbers (these need updating — see correct values below). Quote: "AeroMedica ไม่ใช่แค่เกม แต่มันคือเครื่องมือสำหรับสังคม... ทุกชั่วโมงของการฝึกฝนในระบบจำลองนี้ คือความพร้อมที่อาจช่วยชีวิตคนได้จริงในอนาคต". Open Source on GitHub. Background: real EMT CPR photo.
**Script guidance:** This is the emotional closing. State the numbers with pride. Deliver the quote with conviction. This is the moment that should leave an impression on the judges. The message: every hour of practice in this simulation is preparation that could save a real life in the future.

**IMPORTANT — Correct values for slide 14:**
- **25** วันในการพัฒนา (Days) — NOT 22
- **86** เซสชั่นการทำงาน (Dev Sessions) — NOT 72
- **22+** บั๊กที่ถูกแก้ไข (Bugs Fixed) — this one is correct

### Slide 15 — Deploy Immediately (ทดลองใช้งานทันที)
**Visual:** Two QR codes: GitHub Repository (source code) and Google Drive (download and play immediately). 3-step flow: 1. Download → 2. Extract → 3. Play (run AeroMedica.exe). Bottom: [OPTIONAL] Install Ollama to unlock full AI features (game works with cached feedback without AI).
**Script guidance:** Final call to action. Invite judges to try it. Three steps: download, extract, play. Mention that Ollama is optional — the game works without it. Thank the judges. End with confidence. 15-20 seconds.

---

## TIMING GUIDE (10 minutes total)

| Slide | Topic | Suggested Time | Cumulative |
|-------|-------|---------------|-----------|
| 1 | Title | 0:15 | 0:15 |
| 2 | Skill Decay Crisis | 0:50 | 1:05 |
| 3 | The Missing Link | 0:35 | 1:40 |
| 4 | Gameplay Loop | 0:35 | 2:15 |
| 5 | Four Panels | 0:55 | 3:10 |
| 6 | Real Protocols | 0:45 | 3:55 |
| 7 | Escalation Matrix | 0:55 | 4:50 |
| 8 | Privacy / Offline | 0:45 | 5:35 |
| 9 | Scoring | 0:45 | 6:20 |
| 10 | Paradigm Shift | 0:25 | 6:45 |
| 11 | Open Source Stack | 0:25 | 7:10 |
| 12 | B2B Ecosystem | 0:35 | 7:45 |
| 13 | Instructor Dashboard | 0:35 | 8:20 |
| 14 | Traction & Vision | 0:45 | 9:05 |
| 15 | Deploy / CTA | 0:20 | 9:25 |
| — | Buffer / pauses | 0:35 | 10:00 |

---

## KEY NUMBERS (use these exact values)

| Metric | Value |
|--------|-------|
| Development period | 25 days (7-31 March 2026) |
| Development sessions | 86 |
| Scenarios | 5 playable |
| Patients | 14 unique (+1 random event in MCI) |
| DDx conditions | 47 across 6 categories |
| Vital signs measured | 8 |
| ECG rhythms | 7 |
| DRSABCDE steps | 8 |
| Head-to-Toe regions | 7 |
| Scoring axes | 5 |
| Cached reviews | 70 (7 x 5 x 2) |
| Translation keys | 300+ (Thai + English) |
| Medical bag BLS items | 24+ |
| Medical bag ALS items | 17 additional |
| Bugs fixed | 22+ |
| Autoload singletons | 13 |

---

## KEY PHRASES TO USE

- "Supplement, not replace" — we supplement real training, we don't claim to replace it
- "สะพานเชื่อมระหว่างห้องเรียนกับสถานการณ์ฉุกเฉินจริง" — bridge between classroom and real emergency
- "Zero Infrastructure Cost" — no server, no subscription, no data leaves the building
- "ผู้เล่นได้รับ feedback ทุกกรณี" — players get feedback regardless of whether AI is available
- "ทำงานออฟไลน์สมบูรณ์" — works 100% offline
- "ข้อมูลผ่านการตรวจสอบความถูกต้องทางคลินิก" — data is clinically verified

## PHRASES TO AVOID

- "Metaverse" — the project is a training simulation, not a metaverse platform
- "ทุกห้องเรียน" / "every classroom" — AI needs 8GB+ RAM, not every machine can run it
- "70 ไฟล์" — say "70 รายการ" instead (it's 1 JSON file with 70 entries)
- Any claim that this replaces real clinical training
- Any specific price or revenue projections (not asked for, would be speculation)

---

## RESEARCH CITATIONS

Use these when discussing the problem (Slide 2):
1. **Stept & Stross, 1980** — Annals of Emergency Medicine — Paramedic skill degradation of 61% within 2 years
2. **Smith et al., 2008** — ACLS pass rates drop from ~100% to 14% at 12 months post-certification
