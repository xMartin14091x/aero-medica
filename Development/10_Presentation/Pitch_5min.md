# AeroMedica — Final Pitch Script (5 Minutes)

**Event:** Thailand Metaverse Hackathon and Exhibition 2026 — Final Round
**Track:** การแพทย์
**Team:** Ollama Paramedic
**Total Time:** 5:00

---

## Slide 1 — Title (0:00 - 0:10) [10 sec]

**Visual:** AeroMedica banner + team name + track + tagline

**Script:**
"สวัสดีครับ ทีม Ollama Paramedic นำเสนอ AeroMedica: Protocol Playground ระบบจำลองการฝึกอบรมแพทย์ฉุกเฉินแบบ 3 มิติ ที่ทำงานออฟไลน์สมบูรณ์ครับ"

---

## Slide 2 — Problem (0:10 - 0:55) [45 sec]

**Visual:** Statistics graphic — degradation curve, pass rate drop chart

**Script:**
"ในฐานะบุคลากรทางการแพทย์ฉุกเฉิน ทุกวินาทีมีค่า แต่ปัญหาที่เราพบคือ ทักษะทางการแพทย์ฉุกเฉินเสื่อมถอยอย่างรวดเร็วหลังจบการฝึกอบรม

งานวิจัยของ Stept & Stross ในวารสาร Annals of Emergency Medicine พบว่าทักษะ Paramedic ลดลงถึง 61% ภายใน 2 ปี และงานวิจัยของ Smith พบว่า ACLS pass rate ลดเหลือเพียง 14% หลังผ่านไปแค่ 12 เดือน

ปัจจุบันการฝึกซ้อมสถานการณ์จริงมีข้อจำกัดหลายประการ — ใช้ทรัพยากรสูง ต้องมีหุ่นจำลอง สถานที่ และผู้ฝึกสอน จัดได้ไม่บ่อย และที่สำคัญคือทำซ้ำไม่ได้ในสถานการณ์เดิม

สิ่งที่บุคลากรต้องการคือ เครื่องมือที่ฝึกซ้ำได้ทุกวัน โดยไม่ต้องพึ่งพาทรัพยากรภายนอกครับ"

**Key Points:**
- 61% skill degradation in 2 years (Stept & Stross, 1980, Annals of Emergency Medicine)
- ACLS pass rate drops to 14% at 12 months (Smith et al., 2008)
- Real drills: expensive, require mannequins + venue + instructors, infrequent, non-repeatable
- Need: daily repeatable practice tool with zero external dependencies

---

## Slide 3 — Solution Overview (0:55 - 1:25) [30 sec]

**Visual:** Game screenshot (isometric view with patient) + feature icons

**Script:**
"AeroMedica คือเกมจำลองสถานการณ์ฉุกเฉินแบบ 3 มิติ มุมมอง Isometric พัฒนาด้วย Godot 4.6 ผู้เล่นรับบทเป็น EMT ประเมินผู้ป่วยตามมาตรฐานจริงทุกขั้นตอน

ตั้งแต่ DRSABCDE Primary Survey, วัด Vital Signs 8 ค่า, อ่าน ECG, ประเมิน GCS, ตรวจร่างกายตั้งแต่ศีรษะถึงปลายเท้า, ซักประวัติด้วย SAMPLE, ให้ยาตามขนาดและช่องทาง, ทำ CPR + AED พร้อม ROSC Logic, คัดแยกด้วย START Triage, และวินิจฉัยแยกโรคจาก 47 อาการ

ทั้งหมดทำงานออฟไลน์สมบูรณ์ ไม่ต้องพึ่งพาอินเทอร์เน็ตครับ"

**Key Points:**
- Godot 4.6, 3D isometric
- Full DRSABCDE, Vital Signs, ECG, GCS, Head-to-Toe, SAMPLE, Drug Admin, CPR+AED, START Triage, DDx (47 conditions)
- 100% offline

---

## Slide 4 — Live Demo (1:25 - 3:25) [120 sec]

**Visual:** Switch to live game OR pre-recorded video with live narration

**Script:**

### Part A — Tutorial Walkthrough (90 sec)

"เพื่อให้เห็นภาพการทำงานจริง เราขอสาธิตผ่านฉาก Tutorial ครับ ในฉากนี้เราพบผู้ป่วย 1 ราย คือคุณสมชาย อายุ 28 ปี ประสบอุบัติเหตุหกล้ม

**ขั้นตอนแรก — Primary Survey**
เราเริ่มประเมินตามลำดับ DRSABCDE โดยกดปุ่มตามขั้นตอน ตั้งแต่ประเมินความปลอดภัยของที่เกิดเหตุ ระดับการรู้สึกตัว ทางเดินหายใจ การหายใจ ไปจนถึงระบบไหลเวียนเลือด ซึ่งระบบจะบันทึกลำดับทุกขั้นตอนที่เราทำ เพื่อนำไปเปรียบเทียบกับ Protocol ที่ถูกต้องในภายหลัง

**ขั้นตอนที่สอง — Head-to-Toe**
จากนั้นเราตรวจร่างกายทีละส่วน เมื่อคลิกที่ศีรษะ ระบบแสดงผลว่าพบแผลฉีกขนาดเล็กที่หน้าผาก GCS 15 และเมื่อตรวจที่แขนขา พบรอยถลอกที่แขนซ้าย Capillary Refill 2 วินาที ข้อมูลทั้งหมดนี้ผ่านการตรวจสอบความถูกต้องทางคลินิกแล้วครับ

**ขั้นตอนที่สาม — SAMPLE History**
เราซักประวัติผู้ป่วยผ่านระบบ AI ออฟไลน์ คุณสมชายจะตอบกลับอย่างเป็นธรรมชาติ เช่น 'ผมลื่นล้มหัวฟาดราวครับ' พร้อมให้ข้อมูลประวัติแพ้ยา ยาที่ใช้ และโรคประจำตัว หากเครื่องไม่รองรับ AI ระบบจะใช้บทสนทนาสำเร็จรูปที่เตรียมไว้แทนโดยอัตโนมัติ

**ขั้นตอนที่สี่ — การรักษาเบื้องต้น**
เมื่อประเมินครบแล้ว เราเปิดกระเป๋าพยาบาลเพื่อเลือกอุปกรณ์ ทำแผลที่หน้าผากด้วย Bandage และพันผ้ากดห้ามเลือดที่แขนด้วย Pressure Dressing โดยอุปกรณ์แต่ละชิ้นมีจำนวนจำกัด ผู้เล่นต้องบริหารทรัพยากรเอง

**ขั้นตอนสุดท้าย — Triage และ Diagnosis**
เนื่องจากสัญญาณชีพคงที่และเดินได้ เราติดป้าย Triage สีเขียว และเลือกคำวินิจฉัยว่า Minor Bleeding และ Soft Tissue Injury ซึ่งตรงกับคำตอบที่ถูกต้องในฐานข้อมูล ทำให้ได้คะแนนเต็มในหมวด Decision Quality ครับ"

### Part B — Scenario Scale (30 sec)

"นอกจาก Tutorial เรามีอีก 4 สถานการณ์ที่ซับซ้อนขึ้น ตั้งแต่อุบัติเหตุจราจร 3 ผู้ป่วย, หัวใจหยุดเต้นที่ต้องทำ CPR + AED, อาคารไฟไหม้ที่มี Hazard Zone ทำอันตรายผู้เล่น ไปจนถึง Mass Casualty 6 ผู้ป่วยพร้อมกันที่ต้องคัดแยกภายใต้แรงกดดันของเวลา

ผู้ป่วยทุกคนมีสัญญาณชีพ ประวัติ และอาการเฉพาะตัว — ไม่มีผู้ป่วยซ้ำกันเลยครับ"

**Demo Flow (if live):**
1. Open Tutorial → approach Somchai
2. Tap DRSABCDE in sequence (show protocol tracking)
3. Head-to-Toe → click Head → show findings
4. SAMPLE → show AI dialogue bubbles
5. Medical Bag → apply Bandage + Pressure Dressing
6. Triage → GREEN tag
7. DDx → select correct diagnosis → score popup
8. Quick flash: scenario select showing 5 scenarios with difficulty stars

---

## Slide 5 — AI System (3:25 - 3:55) [30 sec]

**Visual:** Diagram: Ollama → Patient Dialogue + AI Review → Cached Fallback

**Script:**
"ระบบ AI ของเราใช้ Ollama กับ llama3.1:8b ทำงานบนเครื่องผู้เล่นโดยตรง ไม่ส่งข้อมูลออกนอกเครือข่าย

AI มี 2 บทบาท: หนึ่งคือเป็นผู้ป่วยจำลองที่ตอบคำถามตามข้อมูลทางการแพทย์ของตัวเอง และสองคือเป็นผู้ตรวจประเมินที่วิเคราะห์ Telemetry ทั้งหมดแล้วสร้าง Feedback เป็นภาษาไทยหรืออังกฤษ

ตัวเกมรันได้บนทุกเครื่อง ส่วน AI แนะนำเครื่องที่มี RAM 8GB ขึ้นไป หากเครื่องไม่รองรับ ระบบจะใช้ Cached Review ที่เตรียมไว้ 70 รายการแทนโดยอัตโนมัติ ผู้เล่นได้รับ feedback ทุกกรณีครับ"

**Key Points:**
- Ollama llama3.1:8b — runs locally, no cloud
- Two roles: patient dialogue + performance reviewer
- Auto-discovery on localhost + LAN IPs
- 70 cached reviews (7 scenarios x 5 tiers x 2 languages) as fallback

---

## Slide 6 — Scoring & Debrief (3:55 - 4:25) [30 sec]

**Visual:** Debrief screen — radar chart + AI review + Dashboard tab

**Script:**
"เมื่อจบสถานการณ์ ระบบให้คะแนน 5 แกน ได้แก่ ความเร็ว Triage, ความถูกต้องของ Protocol, คุณภาพการตัดสินใจ, การใช้อุปกรณ์ และผลลัพธ์ของผู้ป่วย แสดงเป็น Radar Chart

AI Reviewer ให้ Feedback ละเอียดว่าทำอะไรถูก ทำอะไรพลาด และควรปรับปรุงอย่างไร

Dashboard ติดตามพัฒนาการของผู้เล่น มีกราฟแสดงแนวโน้มคะแนน และส่งออกข้อมูลเป็น CSV หรือ JSON ได้ สำหรับสถาบันที่ต้องการวิเคราะห์ข้อมูลเพิ่มเติมครับ"

**Key Points:**
- 5-axis radar chart (Triage Speed, Protocol Accuracy, Decision Quality, Equipment Handling, Patient Outcome)
- AI natural language feedback — bilingual
- Dashboard: My Performance + Scenario Breakdown
- CSV/JSON data export for institutional analysis

---

## Slide 7 — Business Model (4:25 - 4:45) [20 sec]

**Visual:** B2B diagram — institutions → AeroMedica → students

**Script:**
"กลุ่มเป้าหมายของเราคือ B2B — สถาบันฝึกอบรมแพทย์ฉุกเฉิน โรงพยาบาล และหน่วยงาน EMS

จุดขายคือ Zero Infrastructure Cost — ไม่ต้องมี server ไม่ต้องมี subscription ไม่มีข้อมูลนักเรียนออกนอกอาคาร ทุกอย่างทำงานบนเครื่องในห้องเรียนครับ"

**Key Points:**
- B2B: training institutions, hospitals, EMS agencies
- Zero infrastructure cost — no server, no subscription, no data leaves the building
- Cross-platform (Windows, macOS, Linux via Godot export)

---

## Slide 8 — Closing (4:45 - 5:00) [15 sec]

**Visual:** Impact statement + download QR/link + team photo

**Script:**
"AeroMedica: Protocol Playground ไม่ใช่แค่เกม แต่คือสะพานเชื่อมระหว่างห้องเรียนกับสถานการณ์ฉุกเฉินจริง พัฒนาใน 25 วัน 86 เซสชัน พร้อมให้ดาวน์โหลดทดลองใช้ได้แล้ววันนี้ครับ ขอบคุณครับ"

**Key Points:**
- Impact statement
- 25 days / 86 sessions
- Available now
- Thank you
