# AeroMedica — Final Pitch Script (10 Minutes)

**Event:** Thailand Metaverse Hackathon and Exhibition 2026 — Final Round
**Track:** การแพทย์
**Team:** Ollama Paramedic
**Total Time:** 10:00

---

## Slide 1 — Title (0:00 - 0:15) [15 sec]

**Visual:** AeroMedica banner + team name + track + tagline + team member names

**Script:**
"สวัสดีครับ ทีม Ollama Paramedic นำเสนอ AeroMedica: Protocol Playground ระบบจำลองการฝึกอบรมแพทย์ฉุกเฉินแบบ 3 มิติ ที่ออกแบบมาเพื่อเปลี่ยนการเรียนรู้จากตำราเรียนแบบ Passive ให้เป็นการฝึกปฏิบัติแบบ Active สำหรับบุคลากรทางการแพทย์ฉุกเฉินครับ"

---

## Slide 2 — Problem Statement (0:15 - 1:15) [60 sec]

**Visual:** Two charts side by side — skill degradation curve + pass rate timeline

**Script:**
"ก่อนอื่นขอเล่าถึงปัญหาที่เราต้องการแก้ไขครับ

ในวงการแพทย์ฉุกเฉิน ทักษะที่ได้จากการฝึกอบรมเสื่อมถอยอย่างรวดเร็ว งานวิจัยของ Stept & Stross ตีพิมพ์ใน Annals of Emergency Medicine พบว่าทักษะ Paramedic ลดลงถึง 61% ภายใน 2 ปีหลังจบการฝึก และงานวิจัยของ Smith และคณะพบว่า ACLS pass rate ลดจากเกือบ 100% เหลือเพียง 14% ในเวลาเพียง 12 เดือน

ปัจจุบันการฝึกซ้อมสถานการณ์จริงมีข้อจำกัดหลายประการ ต้องใช้หุ่นจำลองราคาแพง ต้องมีสถานที่และผู้ฝึกสอน จัดได้เพียงไม่กี่ครั้งต่อปี และที่สำคัญที่สุดคือทำซ้ำในสถานการณ์เดิมไม่ได้

ผลลัพธ์คือ บุคลากรที่ผ่านการฝึกอบรมมาอย่างดี กลับสูญเสียทักษะวิกฤตไปก่อนที่จะได้ใช้งานจริง สิ่งที่ต้องการคือเครื่องมือที่ฝึกซ้ำได้ทุกวัน โดยไม่ต้องพึ่งพาทรัพยากรภายนอกครับ"

**Key Points:**
- 61% skill degradation in 2 years (Stept & Stross, 1980, Annals of Emergency Medicine)
- ACLS pass rate drops to 14% at 12 months (Smith et al., 2008)
- Real drill constraints: expensive mannequins, venue, instructors, low frequency
- Non-repeatable scenarios — can't practice the same case twice
- The gap: well-trained personnel losing critical skills before they're needed

---

## Slide 3 — Solution Overview (1:15 - 2:00) [45 sec]

**Visual:** Game screenshot (isometric view) + annotated feature callouts

**Script:**
"AeroMedica: Protocol Playground คือคำตอบของเราครับ เป็นเกมจำลองสถานการณ์ฉุกเฉินแบบ 3 มิติ มุมมอง Isometric พัฒนาด้วย Godot 4.6

ผู้เล่นรับบทเป็น EMT ที่ต้องประเมินผู้ป่วยตามมาตรฐานจริงทุกขั้นตอน ตั้งแต่ DRSABCDE Primary Survey 8 ขั้นตอน, วัด Vital Signs 8 ค่าโดยต้อง Deploy อุปกรณ์ก่อนอ่านค่า, อ่าน ECG 7 จังหวะหัวใจ, ประเมิน GCS, ตรวจร่างกาย Head-to-Toe 7 บริเวณพร้อมระบุความรุนแรง, ซักประวัติด้วย SAMPLE ผ่าน AI, ให้ยาตามขนาดและช่องทางที่ถูกต้อง, ทำ CPR + AED พร้อม ROSC Logic, คัดแยกด้วย START Triage 4 ระดับ, และวินิจฉัยแยกโรคจาก 47 อาการ

ทั้งหมดนี้ทำงานออฟไลน์สมบูรณ์ ไม่ต้องพึ่งพาอินเทอร์เน็ต และรองรับ 2 ภาษาทั้งไทยและอังกฤษครับ"

**Key Points:**
- Godot 4.6, 3D isometric
- Complete clinical workflow: DRSABCDE → Vitals → ECG → GCS → HtT → SAMPLE → Drug Admin → CPR/AED → Triage → DDx
- 100% offline, bilingual TH/EN

---

## Slide 4 — Live Demo Part 1: Tutorial (2:00 - 4:00) [120 sec]

**Visual:** Switch to live game OR pre-recorded video

**Script:**

"เพื่อให้เห็นภาพการทำงานจริง เราขอสาธิตผ่านฉาก Tutorial ครับ ในฉากนี้เราพบผู้ป่วย 1 ราย คือคุณสมชาย อายุ 28 ปี ประสบอุบัติเหตุหกล้ม

**ขั้นตอนแรก — Primary Survey**
เราเริ่มประเมินตามลำดับ DRSABCDE โดยกดปุ่มตามขั้นตอน ตั้งแต่ประเมินความปลอดภัยของที่เกิดเหตุ ระดับการรู้สึกตัว ทางเดินหายใจ การหายใจ ไปจนถึงระบบไหลเวียนเลือด สังเกตว่าปุ่มแต่ละปุ่มมี Cooldown ป้องกันการกดรัว — เหมือนในสถานการณ์จริงที่ต้องใช้เวลาทำแต่ละขั้นตอน ระบบจะบันทึกลำดับทุกขั้นตอนเพื่อนำไปเปรียบเทียบกับ Protocol ที่ถูกต้อง

**ขั้นตอนที่สอง — Head-to-Toe**
จากนั้นเราตรวจร่างกายทีละส่วน เมื่อคลิกที่ศีรษะ ระบบแสดงผลว่าพบแผลฉีกขนาดเล็กที่หน้าผาก GCS 15 สังเกตเครื่องหมายสีเหลืองที่บ่งบอกว่าเป็นอาการสำคัญ ส่วนเครื่องหมายสีแดงคืออาการวิกฤตที่ต้องรักษาทันที ข้อมูลทั้งหมดนี้ผ่านการตรวจสอบความถูกต้องทางคลินิกแล้วครับ

**ขั้นตอนที่สาม — SAMPLE History**
เราซักประวัติผู้ป่วยผ่านระบบ AI ออฟไลน์ คุณสมชายจะตอบกลับอย่างเป็นธรรมชาติ เช่น 'ผมลื่นล้มหัวฟาดราวครับ' พร้อมให้ข้อมูลประวัติแพ้ยา ยาที่ใช้ และโรคประจำตัว

**ขั้นตอนที่สี่ — การรักษาเบื้องต้น**
เราเปิดกระเป๋าพยาบาลเพื่อเลือกอุปกรณ์ กระเป๋ามี 2 ระดับ: BLS สำหรับฉากพื้นฐาน และ ALS สำหรับฉากขั้นสูงที่มียาฉีดและอุปกรณ์เพิ่มเติม อุปกรณ์แต่ละชิ้นมีจำนวนจำกัด โดยเฉพาะในฉาก Mass Casualty ที่มีผู้ป่วย 6 คนแต่อุปกรณ์เท่าเดิม ผู้เล่นต้องบริหารทรัพยากรเอง

**ขั้นตอนสุดท้าย — Triage และ Diagnosis**
เนื่องจากสัญญาณชีพคงที่และเดินได้ เราติดป้าย Triage สีเขียว และเลือกคำวินิจฉัยว่า Minor Bleeding และ Soft Tissue Injury ซึ่งตรงกับคำตอบที่ถูกต้องในฐานข้อมูลทางการแพทย์ ทำให้ได้คะแนนเต็มในหมวด Decision Quality ครับ"

**Demo Flow:**
1. Open Tutorial → walk to Somchai
2. DRSABCDE → show cooldown rings on buttons
3. Head-to-Toe → click Head → show severity marker (yellow)
4. SAMPLE History → show chat bubbles with AI response
5. Medical Bag → show BLS/ALS tier label → apply Bandage + Pressure Dressing
6. Triage → GREEN tag → show tag applied
7. DDx → search "Minor" → select correct → show score

---

## Slide 5 — Scenarios & Difficulty Scaling (4:00 - 5:00) [60 sec]

**Visual:** 5 scenario cards with screenshots — difficulty progression

**Script:**
"นอกจาก Tutorial เรามี 5 สถานการณ์ที่ไล่ระดับความยากขึ้นครับ

**Tutorial** — 1 ผู้ป่วย ไม่จำกัดเวลา เหมาะสำหรับเรียนรู้ระบบ

**Road Traffic Accident** — อุบัติเหตุจราจร 3 ผู้ป่วยที่มีอาการต่างกัน ตั้งแต่คนที่เดินได้จนถึงคนที่หมดสติ ต้องตัดสินใจว่าจะรักษาใครก่อน

**Cardiac Arrest** — หัวใจหยุดเต้น 1 ผู้ป่วย จำกัดเวลา 5 นาที ต้องทำ CPR กดหลังประเมิน Pulse เท่านั้น ใช้ AED ตรวจจังหวะหัวใจ ถ้าเป็น Shockable rhythm จะ Shock ได้ มีโอกาส ROSC 70% หลัง AED

**Building Fire** — อาคารไฟไหม้ 3 ผู้ป่วย พร้อม Hazard Zone ที่ไฟทำอันตรายผู้เล่นจริง ถ้ายืนในโซนไฟนาน 15 วินาที EMT จะ Incapacitated เล่นต่อไม่ได้

**Mass Casualty Incident** — ระเบิดตลาด 6 ผู้ป่วยพร้อมกัน ตั้งแต่สีเขียวถึงสีดำ ต้องคัดแยกภายใต้แรงกดดันของเวลา อุปกรณ์จำกัด และมีผู้ป่วยรายใหม่เข้ามาระหว่างเล่น

ผู้ป่วยทุกคนมี สัญญาณชีพ ประวัติ อาการ และ Deterioration Rate เฉพาะตัว — ถ้าไม่รักษาทันเวลา ผู้ป่วยจะเสื่อมถอยจาก Conscious ไปจนถึงเสียชีวิตได้จริงครับ"

**Key Points:**
- 5 scenarios: Tutorial → RTA → Cardiac → Fire → MCI
- Difficulty 1/5 to 5/5
- Patient deterioration: CONSCIOUS → UNCONSCIOUS → CARDIAC_ARREST → DEAD
- Hazard zones (fire damage to EMT)
- Resource management: limited equipment across multiple patients
- Random events: new patient arrives mid-scenario in MCI

---

## Slide 6 — AI System Deep Dive (5:00 - 6:00) [60 sec]

**Visual:** Architecture diagram: Ollama → 2 roles → Fallback path

**Script:**
"ระบบ AI ของเราใช้ Ollama กับ llama3.1:8b ทำงานบนเครื่องผู้เล่นโดยตรง ไม่ส่งข้อมูลออกนอกเครือข่าย เลือก Ollama เพราะทำงานออฟไลน์ได้ 100% ไม่ต้องพึ่งพา Cloud API

AI มี 2 บทบาทครับ

**บทบาทที่หนึ่ง — Patient Dialogue** AI รับบทเป็นผู้ป่วยจำลอง ตอบคำถามตามข้อมูลทางการแพทย์ของตัวเอง ชื่อ อายุ อาการ ประวัติ ยาที่ใช้ ทั้งหมดถูกกำหนดไว้ใน PatientPersona ทำให้ AI ตอบสอดคล้องกับสถานการณ์

**บทบาทที่สอง — AI Reviewer** หลังจบสถานการณ์ AI วิเคราะห์ Telemetry ทั้งหมดที่ระบบบันทึกไว้ — ลำดับการประเมิน การใช้ยา เวลาที่ใช้ สถานะผู้ป่วยขณะให้ยา แล้วสร้าง Feedback เป็นภาษาไทยหรืออังกฤษ

**ระบบ Auto-Discovery** เกมจะค้นหา Ollama อัตโนมัติบน localhost, 127.0.0.1, และ IP ทุกตัวในเครือข่าย LAN ไม่ต้องตั้งค่าใดๆ

**Fallback** ตัวเกมรันได้บนทุกเครื่อง ส่วน AI แนะนำ RAM 8GB ขึ้นไป หากเครื่องไม่รองรับ ระบบจะใช้ Cached Review ที่เตรียมไว้ 70 รายการ ครอบคลุมทุกสถานการณ์ ทุกระดับผลงาน ทั้ง 2 ภาษา แทนโดยอัตโนมัติ ผู้เล่นได้รับ feedback ทุกกรณีครับ"

**Key Points:**
- Ollama llama3.1:8b — local, offline, no cloud dependency
- Role 1: Patient dialogue grounded in PatientPersona data
- Role 2: Post-scenario Telemetry analysis → structured feedback
- Auto-discovery: localhost + 127.0.0.1 + all LAN IPs on port 11434
- Cached fallback: 70 reviews (7 scenarios x 5 tiers x 2 languages)
- Game works on any machine; AI is a bonus layer

---

## Slide 7 — Scoring & Debrief (6:00 - 7:00) [60 sec]

**Visual:** Debrief screen (radar chart + AI text) + Dashboard (2 tabs)

**Script:**
"เมื่อจบสถานการณ์ ระบบวิเคราะห์ผลงานผ่าน Scoring Engine ที่ให้คะแนน 5 แกนครับ

**Triage Speed** — ทำ triage แรกภายใน 1 นาทีได้คะแนนเต็ม ยิ่งช้าคะแนนยิ่งลด
**Protocol Accuracy** — ระบบเปรียบเทียบลำดับการกระทำของผู้เล่นกับ Protocol ที่ถูกต้อง
**Decision Quality** — ป้าย Triage ตรงกับสถานะผู้ป่วยหรือไม่ วินิจฉัยถูกต้องหรือไม่
**Equipment Handling** — เลือกอุปกรณ์เหมาะสมกับอาการหรือไม่
**Patient Outcome** — ผู้ป่วยรอดหรือเสียชีวิต สถานะสุดท้ายเทียบกับสถานะเริ่มต้น

ผลแสดงเป็น Radar Chart ให้เห็นจุดแข็งจุดอ่อนในทันที

AI Reviewer ให้ Feedback ละเอียดเป็นภาษาธรรมชาติ วิเคราะห์ว่าทำอะไรถูก ทำอะไรพลาด และให้คำแนะนำเฉพาะเจาะจง

Dashboard ติดตามพัฒนาการ มี 2 แท็บ: ผลงานของฉัน แสดงภาพรวมและแนวโน้ม กับ แยกตามสถานการณ์ ที่เจาะลึกแต่ละฉาก ส่งออกข้อมูลเป็น CSV หรือ JSON สำหรับสถาบันที่ต้องการวิเคราะห์เพิ่มเติมครับ"

**Key Points:**
- 5 axes explained with what each measures
- Radar chart for visual strength/weakness identification
- AI natural language feedback — specific, actionable
- Dashboard 2 tabs: My Performance + Scenario Breakdown
- Trend graphs + CSV/JSON export for institutional analysis

---

## Slide 8 — Business Model & Target (7:00 - 7:40) [40 sec]

**Visual:** B2B model diagram + target customer list

**Script:**
"กลุ่มเป้าหมายของเราคือ B2B ครับ สถาบันฝึกอบรมแพทย์ฉุกเฉิน โรงพยาบาล สถาบันการศึกษาทางการแพทย์ และหน่วยงาน EMS

จุดขายหลักคือ Zero Infrastructure Cost — ไม่ต้องมี server ไม่ต้องมี subscription ไม่มีข้อมูลนักเรียนออกนอกอาคาร ทุกอย่างทำงานบนเครื่องในห้องเรียน

สถาบันสามารถติดตั้งบนเครื่องคอมพิวเตอร์ในห้องแล็บ เปิดให้นักเรียนฝึกซ้ำได้ไม่จำกัดจำนวนครั้ง โดยไม่ต้องจ่ายค่าใช้จ่ายรายเดือน ข้อมูลทั้งหมดอยู่ในเครื่อง สอดคล้องกับนโยบายความปลอดภัยข้อมูลของสถาบันการศึกษาครับ"

**Key Points:**
- B2B: EMT training institutions, hospitals, medical schools, EMS agencies
- Zero infrastructure: no server, no subscription, no recurring cost
- Data stays on-premises — privacy compliant
- Unlimited practice sessions per student
- Cross-platform via Godot export

---

## Slide 9 — Development Process (7:40 - 8:20) [40 sec]

**Visual:** Timeline graphic (Phase 0-8) + key numbers

**Script:**
"AeroMedica พัฒนาใน 25 วัน 86 เซสชัน ตั้งแต่วันที่ 7 ถึง 31 มีนาคม 2569

ใช้กระบวนการ Agile Iterative แบบ Phase-based 9 เฟส ตั้งแต่โครงสร้างพื้นฐาน ระบบ Gameplay หลัก ระบบทางการแพทย์ AI Pipeline สภาพแวดล้อม UI ขั้นสูง Scoring Bug Fixing จนถึง Polish สุดท้าย

ทุกการเปลี่ยนแปลงโค้ดต้องมี Ticket ก่อน ทุกเซสชันถูกบันทึกใน Development Log AI ที่ใช้ในกระบวนการพัฒนาเปิดเผยทั้งหมดใน CONTRIBUTION.md — ทีมเป็นผู้ตัดสินใจ ออกแบบ และควบคุมทุกจุด AI เป็นเครื่องมือเฉพาะทางครับ"

**Key Points:**
- 25 days, 86 sessions (7-31 March 2026)
- 9 phases: Infrastructure → Gameplay → Medical → AI → Environment → UI → Scoring → Bug Fixing → Polish
- Ticket-driven: no code without ticket
- Full development log documented
- AI tools disclosed transparently in CONTRIBUTION.md

---

## Slide 10 — Future Roadmap (8:20 - 9:00) [40 sec]

**Visual:** Roadmap timeline — v1.0 (now) → v2.0 features

**Script:**
"สำหรับแผนพัฒนาต่อไปครับ

**Instructor Web Dashboard** — ระบบเว็บสำหรับผู้สอนดูข้อมูลนักเรียนแบบ real-time ผ่าน LAN ผู้สอนเปิด browser เห็นว่านักเรียนคนไหนกำลังเล่นฉากอะไร คะแนนเท่าไหร่ ติดขัดตรงไหน โดยไม่ต้องเดินไปดูทุกเครื่อง แผนนี้ได้รับการอนุมัติแล้วและพร้อมดำเนินการ

**v2.0 Features** ตามคำแนะนำจากอาจารย์ที่ปรึกษา ได้แก่ Step-Up Timer ที่ผู้ป่วยที่ยังไม่ถูกประเมินจะเสื่อมถอยเร็วขึ้น บังคับให้ต้อง Triage จริงๆ, Adverse Drug Effects ที่ให้ยาผิดแล้วเห็นผลเสียบนจอ, และ Simplified Mode สำหรับผู้ที่ไม่ใช่บุคลากรทางการแพทย์

สถานการณ์ใหม่เพิ่มได้ง่ายเพราะทุกอย่างขับเคลื่อนด้วย JSON ไม่ต้องแก้โค้ดครับ"

**Key Points:**
- Instructor Web Dashboard: FastAPI + SQLite + WebSocket, browser-based, LAN, approved and ready
- v2.0 mentor-recommended features: Step-Up Timer, Adverse Drug Effects, Simplified Mode
- JSON-driven scenario system — new scenarios without code changes
- Scalable to more conditions, more patients, more hazard types

---

## Slide 11 — Closing (9:00 - 10:00) [60 sec]

**Visual:** Impact statement + key numbers + download QR/link + team

**Script:**
"สรุปครับ AeroMedica: Protocol Playground ไม่ใช่แค่เกม แต่คือสะพานเชื่อมระหว่างห้องเรียนกับสถานการณ์ฉุกเฉินจริง

เราสร้างระบบที่ครอบคลุม Protocol ทางการแพทย์ฉุกเฉินตั้งแต่ DRSABCDE จนถึงการวินิจฉัยแยกโรค มี AI ที่ทำงานออฟไลน์สมบูรณ์ มี 5 สถานการณ์ที่ไล่ระดับความยาก ผู้ป่วย 14 คนที่แต่ละคนมีอาการเฉพาะตัว ระบบ Scoring 5 แกนพร้อม AI Feedback และ Dashboard ติดตามพัฒนาการ

ทั้งหมดนี้ไม่ต้องใช้อินเทอร์เน็ต ไม่ต้องมี server ข้อมูลไม่ออกนอกอาคาร พร้อมใช้งานได้ทันที

พัฒนาใน 25 วัน 86 เซสชัน พร้อมให้ดาวน์โหลดทดลองใช้ได้แล้ววันนี้ที่ Google Drive

ขอบคุณครับ"

**Key Points:**
- Restate the impact: bridge between classroom and real emergency
- Numbers: 5 scenarios, 14 patients, 47 DDx, 5-axis scoring, 70 cached reviews, bilingual
- Offline, no server, no subscription, data stays local
- 25 days / 86 sessions
- Available now — Google Drive link + QR code
- Thank you + open for Q&A
