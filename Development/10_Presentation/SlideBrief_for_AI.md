# AeroMedica — Slide Generation Brief (Final Round)

**Purpose:** Generate presentation slides for AeroMedica: Protocol Playground — TMH 2026 Final Pitching. The slides must follow the exact same visual style and theme as the previous version (PDF provided as style reference). Same layout structure, same design language, same color palette.

**Context:** 7-minute pitch + 3-minute Q&A. Scoring criteria prioritize: Prototype (40%), Impact (20%), Idea (20%), Pitching (20%). The slide deck supports a live demo segment — no slide needed during demo, but slides before and after frame the demo.

**Language:** Thai for all body text. English for technical terms, labels in square brackets, and parenthetical translations.

**Style Reference:** The previous slide deck PDF is provided alongside this brief. Match that exact visual style — same navy HUD aesthetic, same bracket label patterns, same icon styles, same card/box layouts.

**IMPORTANT:** The "develop part" (development process, session counts, etc.) is excluded from the main pitch per competition rules. Development stats go in backup slides only.

---

## VISUAL THEME (must match exactly)

### Color Palette
- **Background:** Deep navy blue (#0A1628 or similar)
- **Primary text:** White
- **Accent color:** Bright cyan/sky blue (#00B4D8 or similar)
- **Secondary accent:** Light blue for borders and decorative elements
- **Alert/critical:** Red for emphasis (used sparingly — e.g., X marks, critical states)

### Typography Rules
- **Slide titles:** Very large, bold, white. Format: "Thai title (English subtitle)" — e.g., "วิกฤตการถดถอยของทักษะ (The Skill Decay Crisis)"
- **Labels/keywords:** Cyan, uppercase English in square brackets — e.g., `[ AI-POWERED ]`, `[ 100% OFFLINE ]`, `[ ZERO RISK ]`
- **Body text:** White, regular weight, Thai
- **Stat numbers:** Extra-large bold cyan inside square brackets — e.g., `[ 25 ]`

### Design Elements
- **Corner brackets:** Thin cyan L-shaped bracket decorations in top-left and bottom-right corners of every slide — gives a tactical HUD / targeting feel
- **Cards/boxes:** Rounded rectangles with thin cyan borders on dark navy backgrounds — used for feature callouts, comparison cells, info blocks
- **Divider lines:** Thin horizontal cyan lines. The title slide has an ECG heartbeat wave motif on the divider
- **Label tags:** All keywords use the `[ KEYWORD ]` bracket pattern in cyan
- **Icons:** Flat/line-art style in white or cyan — medical, tech, building icons
- **Bottom banner:** Full-width strip with slightly lighter navy background and cyan text for key takeaway statements (used on some slides)

### Consistent Patterns Across All Slides
- Every slide title: Thai first (large), English subtitle in parentheses
- Feature callouts always use `[ KEYWORD ]` bracket pattern in cyan
- Info boxes use thin cyan border on navy card background
- No gradients except on charts/graphs
- No emojis anywhere
- Minimal decoration — bracket frames and thin borders do the visual work
- Overall feel: **tactical medical HUD** — like a military/clinical heads-up display

---

## SLIDE-BY-SLIDE SPECIFICATIONS

The deck has **15 slides** organized into 6 sections matching the pitch script.

---

### SECTION 1: Problem + Solution (Slides 1-3)
**Speaker: Martin | Time: 0:00-1:15 | Targets: Problem Statement, Solution Fit, Differentiation**

---

### Slide 1 — Title
**Thai title:** AeroMedica: Protocol Playground
**Subtitle:** ระบบจำลองการฝึกอบรม 3 มิติสำหรับบุคลากรการแพทย์ฉุกเฉิน (EMT 3D Training Simulator)
**Bottom left:** [ TEAM ] Ollama Paramedic
**Bottom right:** [ EVENT ] TMH 2026
**Design:** Large centered title in white bold. Subtitle below in cyan. Horizontal divider line between title and subtitle with ECG heartbeat wave motif. Corner bracket decorations.

---

### Slide 2 — วิกฤตการถดถอยของทักษะ (The Skill Decay Crisis)
**Layout:** Line graph + stat callout boxes
**Graph:** "Survival Curve" — X-axis: Time (0 to 24 เดือน), Y-axis: Skill Retention (การคงอยู่ทักษะ) 0-100%. Line starts at 100% at month 0, drops steeply to ~14% at month 12, continues to ~0% at month 24. Line color transitions from blue (top) to red (bottom).
**Callout box 1 (near 12-month mark):** `[ -86% ]` อัตราการสอบผ่าน ACLS ลดลงเหลือเพียง 14% ภายใน 12 เดือน (Smith et al., 2008)
**Callout box 2 (near 24-month mark):** `[ -61% ]` ทักษะทางคลินิกเสื่อมถอย 61% ภายใน 2 ปี (Stept & Stross, 1980)
**Bottom banner text:** ทักษะที่สำคัญในเคสวิกฤต (Rarely-encountered cases) คือทักษะที่สูญเสียเร็วที่สุด การฝึกอบรมซ้ำแบบเดิมมีราคาสูงและถูกจำกัดด้วยสถานที่

---

### Slide 3 — เครื่องมือเสริมเพื่ออุดช่องโหว่การฝึกฝน (The Missing Link)
**Layout:** Left → Arrow → Right + feature boxes
**Left side:** Hospital bed illustration with label box: "ห้องปฏิบัติการจำลอง (มีค่าใช้จ่ายสูง, ต้องเดินทาง)"
**Center arrow:** Large arrow pointing right with text `[ SUPPLEMENT, NOT REPLACE ]`
**Right side:** Laptop illustration with label: "การฝึกฝนด้วยตนเอง (ฟรี, ทำได้ทุกที่)"
**Three feature boxes stacked on right:**
- `[ 100% OFFLINE ]` ทลายข้อจำกัดด้านสถานที่และอินเทอร์เน็ต
- `[ AI TELEMETRY ]` ประเมินผลอัตโนมัติโดยไม่ต้องใช้ผู้สอน
- `[ ZERO RISK ]` ทบทวนทักษะอย่างปลอดภัย เพื่อเสริมการฝึกจริง

**NEW — Add differentiation statement at bottom:**
Bottom banner: `[ DIFFERENTIATION ]` ไม่มีเกมจำลองการแพทย์ฉุกเฉินตัวใดที่รวม AI ออฟไลน์ + การประเมิน 5 แกน + โปรโตคอลทางคลินิกครบวงจรไว้ในตัวเดียว

---

### SECTION 2: Live Demo (No slide — game is shown on screen)
**Speaker: JJ | Time: 1:15-2:45 | Targets: Usability, UX/UI, Interesting/Appealing, Problem-Solution Fit**

No slide generated for this section. The presenter switches to the live game or a pre-recorded video. Optionally create a simple **"Live Demo" transition slide** with:
- Title: `สาธิตการทำงานจริง (Live Demonstration)`
- Subtitle: `ฉาก Tutorial — ผู้ป่วย: สมชาย, 28 ปี, หกล้ม`
- Small text: `TALK | EXAMINE | TREAT | DIAGNOSE`

---

### SECTION 3: Escalation + Scoring (Slides 4-6)
**Speaker: Non | Time: 2:45-3:45 | Targets: Prototype depth**

---

### Slide 4 — ระดับความรุนแรงของสถานการณ์ (The Escalation Matrix)
**Layout:** Left difficulty list + right clinical timeline flowchart
**Left side — Difficulty progression (with colored bar indicators):**
- Green bar `[ 1/5 ]` Tutorial (1 ผู้ป่วย / ไม่จำกัดเวลา)
- Yellow bar `[ 2/5 ]` Road Traffic Accident (3 ผู้ป่วย / 10 นาที)
- Yellow bar `[ 3/5 ]` Cardiac Arrest (1 ผู้ป่วย / 5 นาที)
- Orange bar `[ 4/5 ]` Building Fire (3 ผู้ป่วย / 8 นาที)
- Red bar `[ 5/5 ]` Mass Casualty Incident (6+1 ผู้ป่วย / 15 นาที) — ระดับสูงสุด

**Right side — `[ CLINICAL TIMELINE ]` flowchart (vertical):**
- Box: CONSCIOUS → Dashed box: UNCONSCIOUS → Red box: CARDIAC_ARREST → Grey box with flatline: DEAD

---

### Slide 5 — ความเป็นส่วนตัวตั้งแต่การออกแบบ (Privacy by Design — 100% Offline)
**Layout:** Architecture diagram with three zones
**Center large box (LOCAL DEVICE):**
- Header: `[ LOCAL DEVICE ]`: ข้อมูลผู้ป่วยไม่เคยหลุดออกจากเครื่อง
- Game Engine icon → AI chip icon `[ AI ENGINE ]`: Ollama (llama3.1:8b) ประมวลผลบทสนทนาและวิเคราะห์ผล
**Right side:** Internet/cloud icon with large red X
**Bottom:** `[ OFFLINE CACHE ]`: ระบบสำรองข้อความ 70 รายการ (7 สถานการณ์, 5 ระดับคะแนน, 2 ภาษา) การันตีการเล่นเกมได้อย่างต่อเนื่องแม้ไม่มี AI

---

### Slide 6 — วัดผล, ติดตาม, พัฒนา (Measure, Track, Improve)
**Layout:** Left radar chart + right trend graph + feature boxes
**Left — 5-axis radar chart:**
- ความเร็วในการคัดกรอง (Triage Speed)
- ความถูกต้องของโปรโตคอล (Protocol Accuracy)
- คุณภาพการตัดสินใจ (Decision Quality)
- การใช้อุปกรณ์ (Equipment Handling)
- ผลลัพธ์ของผู้ป่วย (Patient Outcome)
**Right — Line chart** showing score improvement trend
**Two feature boxes:**
- `[ SILENT TELEMETRY ]` ระบบให้คะแนนอัตโนมัติทันทีที่จบสถานการณ์
- `[ DATA EXPORT ]` รองรับการนำออกข้อมูลรูปแบบ CSV / JSON สำหรับผู้สอน

---

### SECTION 4: Impact + Scalability (Slides 7-9)
**Speaker: Gun | Time: 3:45-5:00 | Targets: Impact Metrics, Scalability**

---

### Slide 7 — การเปลี่ยนกระบวนทัศน์ (The Paradigm Shift Matrix)
**Layout:** 3-row comparison table
**Header row:** Traditional Training | AeroMedica
**Row 1 — ความสมจริง (Realism):**
- Traditional: ตำราเรียนแบบภาพนิ่งและหุ่นจำลองที่มีข้อจำกัด
- AeroMedica: สภาพแวดล้อม 3 มิติเชิงโต้ตอบ + AI สนทนากับผู้ป่วย
**Row 2 — การประเมินผล (Assessment):**
- Traditional: ต้องใช้ผู้สอนประเมินด้วยตนเองและต้องจัดตารางเวลา
- AeroMedica: AI วิเคราะห์ผลทันที พร้อมคะแนน 5 มิติ (5-axis scoring)
**Row 3 — การเข้าถึง (Access):**
- Traditional: ต้องไปศูนย์ฝึกอบรม มีค่าเดินทางและค่าสถานที่
- AeroMedica: รันแบบออฟไลน์ได้ทุกที่ ไม่มีค่าใช้จ่ายต่อเซสชัน

---

### Slide 8 — เทคโนโลยี Open Source ไร้ค่าลิขสิทธิ์ (The Open Source Stack)
**Layout:** Diamond/grid arrangement of 5 tech components
**Top-left:** `[ ENGINE ]` Godot 4.6 (ไม่มีค่าลิขสิทธิ์)
**Top-right:** `[ AI ]` Ollama (รัน Local AI ฟรี)
**Center:** `[ DATA ]` JSON / CSV (รองรับ 300+ Keys, ไทย/อังกฤษ)
**Bottom-left:** `[ ASSETS ]` Kenney CC0 (ใช้งานฟรีร้อยเปอร์เซ็นต์)
**Bottom-right:** `[ VERSION ]` Git + GitHub
**Bottom banner:** `[ ETHICAL AI ]` การใช้เครื่องมือ AI (Claude Code + Gemini) มีการเปิดเผยอย่างโปร่งใสในไฟล์ CONTRIBUTION.md

---

### Slide 9 — ระบบนิเวศ B2B และผลกระทบ (B2B Ecosystem & Impact)
**Layout:** Three columns with icons + impact banner + scalability callout

**Column 1:** Hospital icon
- `[ HOSPITALS ]` โรงพยาบาล
- ทบทวนทักษะพนักงาน ER ได้ที่หน้างาน
- ลดต้นทุนการใช้หุ่นจำลองและจ้างผู้สอน

**Column 2:** Graduation cap icon
- `[ INSTITUTIONS ]` สถาบันฝึกอบรม EMT
- เครื่องมือเสริมสำหรับการเรียนรู้ภาคปฏิบัติ

**Column 3:** Stethoscope icon
- `[ MEDICAL SCHOOLS ]` โรงเรียนแพทย์
- นักศึกษาฝึกฝนได้ไม่จำกัดรอบ
- ทลายคอขวดด้านตารางเรียน

**Bottom banner:** `[ IMPACT ]` บุคลากร EMT หลายหมื่นคนต้องต่ออายุใบรับรองทุก 2-3 ปี — AeroMedica ขยายการเข้าถึงการฝึกอบรมระดับประเทศ ไม่มีค่าใช้จ่ายต่อเซสชัน

**NEW — Add scalability callout box:**
`[ SCALABILITY ]` สถานการณ์ใหม่เพิ่มได้โดยไม่ต้องแก้โค้ด (JSON-driven) — สถาบันปรับแต่งผู้ป่วย ระดับความยาก ฐานข้อมูลยา และเพิ่มภาษาได้เอง

---

### SECTION 5: Metaverse + Future (Slides 10-11)
**Speaker: Gun | Time: 5:00-5:30 | Targets: Track relevance**

---

### Slide 10 — Metaverse for Society
**Layout:** Concept diagram showing the bridge from virtual to real

**NEW SLIDE — not in previous deck. Design to match theme.**

**Title:** ทำไม Metaverse ถึงสำคัญ (Why Metaverse Matters)

**Center concept:** Three connected nodes in a horizontal flow:
- Left node: `[ VIRTUAL WORLD ]` สภาพแวดล้อม 3 มิติ + ผู้ป่วย AI
- Center node: `[ SKILL TRANSFER ]` ฝึกฝนทักษะในโลกเสมือน
- Right node: `[ REAL WORLD ]` ช่วยชีวิตคนได้จริง

**Tagline in large cyan text:**
"Metaverse for Society — เมื่อทักษะในโลกดิจิทัลช่วยชีวิตคนในโลกจริง"

**Supporting points (small boxes):**
- โต้ตอบกับผู้ป่วย AI เสมือนคนจริง
- ตัดสินใจภายใต้แรงกดดันของเวลา
- Feedback ส่วนบุคคลทุกเซสชัน

---

### Slide 11 — ก้าวต่อไป: แดชบอร์ดสำหรับผู้สอน (Instructor Web Dashboard)
**Layout:** Left-to-right flow (clients → server → dashboard)
**Left:** Three laptop icons `[ GAME CLIENTS ]` ผู้เรียนฝึกฝนผ่านเครื่องข่าย Local
**Center:** Server icon `[ FAST API + WEBSOCKET ]` ส่งข้อมูลเรียลไทม์ (FastAPI + SQLite)
**Right:** Monitor `[ LAN DASHBOARD ]` มอนิเตอร์ผู้เรียนทั้งคลาสแบบ Real-time
**Bottom box:**
- `[ OFFLINE QUEUE ]` ระบบเก็บข้อมูลไว้ในเครื่องหากเน็ตเวิร์คหลุด ซิงค์อัตโนมัติเมื่อเชื่อมต่อใหม่
- พร้อมพัฒนาต่อ

---

### SECTION 6: Closing (Slides 12-13)
**Speaker: Martin | Time: 5:30-6:00 | Targets: Emotional impact**

---

### Slide 12 — วิสัยทัศน์ (Vision)
**Layout:** Large quote + background image

**Large quote in Thai with decorative quotation marks:**
"AeroMedica ไม่ใช่แค่เกม แต่คือสะพานเชื่อมระหว่างห้องเรียนกับสถานการณ์ฉุกเฉินจริง เพื่อสร้างบุคลากรทางการแพทย์ฉุกเฉินที่พร้อมกว่าเดิม"

**Subtitle:** ห้องฝึกปฏิบัติเสมือนจริงที่ทุกสถาบันเข้าถึงได้ โดยไม่ต้องพึ่งพาอินเทอร์เน็ต

**Bottom-right:** Open Source สมบูรณ์แบบบน GitHub

**Background:** Semi-transparent photo of real EMTs performing CPR

**NOTE:** NO development stats (days/sessions/bugs) on this slide. That info is in backup slides only per competition rules.

---

### Slide 13 — ทดลองใช้งานทันที (Deploy Immediately)
**Layout:** Two QR codes + 3-step flow + optional note
**Two QR codes side by side:**
- Left: `[ GITHUB REPOSITORY ]` (พร้อม Source Code)
- Right: `[ GOOGLE DRIVE ]` (ดาวน์โหลดและเล่นได้ทันที)
**3-step flow:**
1. Download `[ โหลดไฟล์ ]`
2. Extract `[ แตกไฟล์ลงเครื่อง ]`
3. Play `[ รัน AeroMedica.exe ]`
**Bottom:** `[ OPTIONAL ]` ติดตั้ง Ollama เพิ่มเติมเพื่อปลดล็อคระบบ AI สนทนากับผู้ป่วยแบบเต็มรูปแบบ (ระบบสามารถทำงานได้โดยใช้ Cached feedback หากไม่มี AI)

**QR Code URLs:**
- GitHub: https://github.com/xMartin14091x/aero-medica
- Google Drive: https://drive.google.com/drive/folders/1rnqWkEMZtg3yYKeX9cIhGl3SZArkfGsf?usp=sharing

---

## BACKUP SLIDES (for Q&A only — not presented in main pitch)

### B1 — 4 แผงควบคุม (Four Panels Detail)
Same as previous Slide 5 — the 2x2 grid: TALK, EXAMINE, TREAT, DIAGNOSE with detailed specs. Use when judges ask about specific features.

### B2 — ความแม่นยำทางการแพทย์ (Medical Accuracy)
Same as previous Slide 6 — 4 verification badges + RTA case study with body diagram. Use when judges ask "How do you ensure accuracy?"

### B3 — ภายใต้แรงกดดันของเวลา (The Gameplay Loop)
Same as previous Slide 4 — circular flow: Spawn → Approach → Assess & Treat → AI Feedback. Use when judges ask about gameplay mechanics.

### B4 — กระบวนการพัฒนา (Development Process)
**NEW — contains the dev stats removed from main pitch:**
- `[ 25 ]` วันในการพัฒนา (Days)
- `[ 86 ]` เซสชันการทำงาน (Dev Sessions)
- `[ 22+ ]` บั๊กที่ถูกแก้ไข (Bugs Fixed)
- Agile Iterative, Phase-based (9 phases), Ticket-driven
- AI tools: Ollama (in-game), Claude Code (code assistant), Gemini (brainstorming)
Use when judges ask "How did you build this?" or "What was your process?"

### B5 — AI Fallback ทำงานอย่างไร (How Offline Fallback Works)
Flowchart: Ollama check → available/unavailable → two paths (live AI vs cached 70 reviews). Use when judges ask "What if the machine can't run AI?"

### B6 — Scalability Detail
JSON example showing how a new scenario is defined. Steps: create JSON → add to scenario select → no code changes. Use when judges ask "Can you add more scenarios?"

---

## SUMMARY: SLIDE COUNT

| # | Slide | Section | New/Existing |
|---|-------|---------|-------------|
| 1 | Title | Problem + Solution | Same as before |
| 2 | Skill Decay Crisis | Problem + Solution | Same (data correct) |
| 3 | The Missing Link | Problem + Solution | Updated: added differentiation banner |
| — | Live Demo transition | Demo | NEW (optional, simple) |
| 4 | Escalation Matrix | Escalation + Scoring | Updated: corrected difficulty order |
| 5 | Privacy by Design | Escalation + Scoring | Updated: 70 รายการ not ไฟล์ |
| 6 | Measure, Track, Improve | Escalation + Scoring | Same |
| 7 | Paradigm Shift | Impact + Scalability | Same |
| 8 | Open Source Stack | Impact + Scalability | Same |
| 9 | B2B Ecosystem | Impact + Scalability | Updated: added impact metrics + scalability |
| 10 | Metaverse for Society | Metaverse | NEW slide |
| 11 | Instructor Dashboard | Metaverse / Future | Same |
| 12 | Vision | Closing | Updated: removed dev stats |
| 13 | Deploy Immediately | Closing | Same |
| B1-B6 | Backup slides | Q&A only | B4 is new (dev process) |

---

## KEY NUMBERS (use these exact values where applicable)

| Metric | Value |
|--------|-------|
| Scenarios | 5 playable |
| Patients | 14 unique (+1 random event in MCI) |
| DDx conditions | 47 across 6 categories |
| Vital signs | 8 |
| ECG rhythms | 7 |
| DRSABCDE steps | 8 |
| Head-to-Toe regions | 7 |
| Scoring axes | 5 |
| Cached reviews | 70 entries (7 x 5 x 2) |
| Translation keys | 300+ (Thai + English) |
| Medical bag items | 40+ total (BLS + ALS) |
