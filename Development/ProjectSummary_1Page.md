# AeroMedica — EMS Training Simulation
### เกมจำลองสถานการณ์ฉุกเฉินทางการแพทย์ 3 มิติ

---

## ปัญหา

การฝึกรับมือผู้ป่วยฉุกเฉินในปัจจุบันต้องใช้หุ่นจำลองราคาสูง อุปกรณ์เฉพาะทาง และผู้สอนที่มีความเชี่ยวชาญ ทำให้คนทั่วไปไม่สามารถเข้าถึงการฝึกอบรมเหล่านี้ได้ เมื่อพบเจอเหตุฉุกเฉินจริง ส่วนใหญ่จึงไม่รู้ว่าควรทำอะไรก่อน — ทุกวินาทีที่ลังเลอาจหมายถึงชีวิตที่สูญเสียไป

## วิธีแก้ — AeroMedica

AeroMedica เปลี่ยนคอมพิวเตอร์ทุกเครื่องให้เป็นห้องจำลองสถานการณ์ฉุกเฉิน ผู้เล่นฝึกประเมินและรักษาผู้ป่วยในโลก 3 มิติที่สมจริง โดยใช้กระบวนการเดียวกับที่ผู้กู้ชีพจริงใช้ — ไม่ต้องซื้ออุปกรณ์ ไม่ต้องมีผู้สอน ไม่ต้องเชื่อมต่ออินเทอร์เน็ต

## Gameplay Loop — 5 ขั้นตอนการเรียนรู้

| ขั้นตอน | ผู้เล่นทำอะไร | ทักษะที่ได้ |
|---------|-------------|-----------|
| **1. ประเมินผู้ป่วย** | ตรวจตามลำดับ DRSABCDE, วัด Vital Signs, ประเมิน GCS | Systematic assessment |
| **2. ซักประวัติ** | สัมภาษณ์ด้วย SAMPLE/OPQRST, สนทนากับ AI แบบไดนามิก | History taking |
| **3. รักษาและให้ยา** | เลือกอุปกรณ์/ยาจาก Medical Bag, ทำ CPR, ติด AED, อ่าน ECG | Clinical decision-making |
| **4. คัดแยก (Triage)** | ใช้ START Triage แบ่ง 4 ระดับสี ภายใน 30 วินาที/คน | Prioritization under pressure |
| **5. วินิจฉัยและ Debrief** | เลือกการวินิจฉัย, รับคะแนนประเมินทุกขั้นตอน | Self-assessment & reflection |

**สภาพผู้ป่วยแย่ลงตามเวลาจริง** — ถ้าไม่รักษาทัน ผู้ป่วยอาจเสียชีวิตได้

## สถานการณ์จำลอง (5 ฉาก)

- **Tutorial** — ผู้ป่วย 1 คน ไม่จำกัดเวลา เรียนรู้ระบบพื้นฐาน
- **Cardiac Arrest** — ผู้ป่วยหัวใจหยุดเต้นในที่ทำงาน (BLS: CPR + AED + ROSC)
- **Road Traffic Accident** — อุบัติเหตุทางถนน 3 ผู้บาดเจ็บ ความรุนแรงต่างกัน + เขตอันตรายไฟ
- **Building Fire** — อพยพผู้ป่วย 3 คน สูดดมควัน CO poisoning + เขตอันตรายไฟ
- **Mass Casualty Incident** — ระเบิดตลาด 6 ผู้บาดเจ็บ + random event ฝึก START Triage

## เทคโนโลยีหลัก

| ระบบ | รายละเอียด |
|------|-----------|
| **Game Engine** | Godot 4.6 (GDScript) — โลก 3D + UI |
| **Patient State Machine** | CONSCIOUS → UNCONSCIOUS → CARDIAC_ARREST → DEAD พร้อม Vital Signs (HR, BP, SpO2, GCS, ECG) |
| **Protocol Validation** | ตรวจลำดับการรักษาตาม DRSABCDE, START Triage, BLS/ALS Protocols |
| **Deterioration System** | อาการแย่ลงตามเวลาจริง — HR เพิ่ม, BP ลด, SpO2 ตก |
| **AI Dialogue** | Ollama (ออฟไลน์) — บทสนทนาผู้ป่วยที่ไม่ซ้ำกัน |
| **Drug Administration** | เลือกยา + ขนาด + ช่องทาง, ติดตาม Medication Error |
| **Telemetry** | บันทึกทุกการกระทำ → Debrief Score + Protocol Adherence Report |
| **AI Reviewer** | Ollama วิเคราะห์ผลงาน + cached fallback (Thai/English) เมื่อออฟไลน์ |
| **Deterioration Budget** | Phase 1: 5 นาที (ก่อน cardiac arrest), Phase 2: 2 นาที (ก่อนเสียชีวิต) — ปรับตามจำนวนผู้ป่วย |
| **Cooldown System** | ปุ่มแต่ละชนิดมี delay + concurrent limit + circular progress overlay |
| **Bilingual** | Thai/English สลับได้ทุกหน้า — TranslationServer + 300+ tr() keys |
| **Dashboard** | 3 tabs: My Performance, Class Overview, Scenario Breakdown + radar chart |
| **ECG Display** | 7 จังหวะหัวใจ (Normal Sinus → Asystole) + strip images |
| **Severity Markers** | ⚠ RED, ⚡ YELLOW, no marker GREEN — Head-to-Toe findings |

## กลุ่มเป้าหมาย

- **หลัก (B2B):** EMT/Paramedic นักเรียน, สถาบันฝึกอบรมแพทย์ฉุกเฉิน
- **รอง (B2C):** บุคลากรทางการแพทย์ ผู้สนใจเรียนรู้

## ผลกระทบที่คาดหวัง

กระจายความรู้ด้านการแพทย์ฉุกเฉินและการปฐมพยาบาลที่ถูกต้องไปสู่คนหมู่มาก ลดค่าใช้จ่ายในการฝึกอบรม และจุดประกายให้ผู้คนสนใจก้าวเข้าสู่วิชาชีพแพทย์หรือผู้กู้ชีพ

## แหล่งอ้างอิงทางการแพทย์

- NASEMSO National Model EMS Clinical Guidelines v2.2 (2019)
- BUMED (US Navy Bureau of Medicine and Surgery) — 18 handbooks
- AHA 2020 ACLS/BLS Guidelines
