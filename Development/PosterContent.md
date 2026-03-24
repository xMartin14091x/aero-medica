# AeroMedica — Poster Content Guide
**Purpose:** Content specification for competition poster design
**Date:** 09-03-2026

---

## Poster Layout Recommendation

### Section 1: Header
- **Project Name:** AeroMedica
- **Tagline:** "EMS Training Simulation — ฝึกรับมือสถานการณ์ฉุกเฉินทางการแพทย์ในโลก 3 มิติ"
- **Team/University Logo**
- **Competition Logo/Name**

### Section 2: Problem Statement
**หัวข้อ:** "ปัญหา"

**เนื้อหา:**
- Icon: ❌ หุ่นจำลองราคาสูง
- Icon: ❌ ต้องมีผู้สอนเฉพาะทาง
- Icon: ❌ เข้าถึงได้ยากสำหรับคนทั่วไป
- Icon: ❌ ไม่มีพื้นที่ปลอดภัยในการฝึกฝน

**ตัวเลขเสริม (ถ้าหาได้):**
- จำนวนผู้เสียชีวิตจาก Cardiac Arrest ต่อปีในไทย
- อัตราการรอด Cardiac Arrest เมื่อได้รับ CPR ภายใน 4 นาที vs. ไม่ได้รับ
- เวลาเฉลี่ยที่รถพยาบาลถึงที่เกิดเหตุ

### Section 3: Solution — AeroMedica
**หัวข้อ:** "AeroMedica — วิธีแก้"

**เนื้อหาหลัก:**
> "เปลี่ยนคอมพิวเตอร์ทุกเครื่องให้เป็นห้องจำลองสถานการณ์ฉุกเฉิน"

**Gameplay Flow Diagram (สำคัญมาก — ควรเป็น visual diagram):**
```
เดินไปหาผู้ป่วย → ประเมิน (DRSABCDE) → ซักประวัติ (SAMPLE/OPQRST)
                                              ↓
        Debrief Score ← วินิจฉัย ← Triage ← รักษา + ให้ยา
```

**5 ขั้นตอนการเรียนรู้ (แต่ละข้อมี icon):**
1. 🔍 ประเมินผู้ป่วย — DRSABCDE + Vital Signs + GCS
2. 💬 ซักประวัติ — SAMPLE/OPQRST + AI Dialogue
3. 💉 รักษาและให้ยา — Medical Bag (BLS/ALS) + Drug Administration
4. 🏷️ คัดแยกผู้ป่วย — START Triage (RED/YELLOW/GREEN/BLACK)
5. 📊 วินิจฉัยและ Debrief — Diagnosis Scoring + Protocol Adherence

### Section 4: Technology Stack
**หัวข้อ:** "เทคโนโลยี"

**Architecture Diagram (simplified):**
```
┌─────────────────────────────┐
│         Godot 4.6           │
│  ┌───────────────────────┐  │
│  │  Medical Simulation   │  │
│  │  • Patient State      │  │
│  │  • Vital Signs        │  │
│  │  • ECG Rhythms        │  │
│  │  • Deterioration      │  │
│  └───────────────────────┘  │
│  ┌───────────────────────┐  │
│  │  Clinical Protocols   │  │
│  │  • DRSABCDE           │  │
│  │  • START Triage       │  │
│  │  • Drug Admin         │  │
│  │  • Protocol Validation│  │
│  └───────────────────────┘  │
│  ┌───────────┐ ┌─────────┐  │
│  │ Ollama AI │ │  JSON   │  │
│  │ (Offline) │ │Scenarios│  │
│  └───────────┘ └─────────┘  │
│  ┌───────────────────────┐  │
│  │  Telemetry Pipeline   │  │
│  │  → Debrief Score      │  │
│  └───────────────────────┘  │
└─────────────────────────────┘
```

**Key Tech Highlights (bullet points with icons):**
- 🎮 Godot 4.6 — 3D game engine (GDScript)
- 🤖 Ollama — Offline AI dialogue (ไม่ต้องอินเทอร์เน็ต)
- 🏥 Patient State Machine — CONSCIOUS → CARDIAC_ARREST → DEAD
- ⏱️ Real-time Deterioration — อาการแย่ลงตามเวลาจริง
- 📋 JSON-driven Scenarios — สถานการณ์สร้างจากข้อมูล
- 📊 Telemetry — บันทึกทุกการกระทำเพื่อ Debrief

### Section 5: Scenarios
**หัวข้อ:** "สถานการณ์จำลอง"

**แสดงเป็น 4 cards:**

| Scenario | ระดับ | ผู้ป่วย | ทักษะหลัก |
|----------|------|--------|----------|
| 🫀 Cardiac Arrest | ⭐⭐ | 1 คน | BLS, CPR, AED |
| 🚗 Road Traffic Accident | ⭐⭐⭐ | 3 คน | Trauma Assessment, Triage |
| 🔥 Building Fire | ⭐⭐ | 1 คน | Airway, CO Poisoning |
| 💥 Mass Casualty | ⭐⭐⭐⭐ | 6 คน | START Triage, Resource Management |

### Section 6: Impact & Target Audience
**หัวข้อ:** "ผลกระทบ"

**กลุ่มเป้าหมาย:**
- 🎮 B2C: บุคคลทั่วไป, ผู้สนใจการแพทย์, เกมเมอร์
- 🏥 B2B: บุคลากรทางการแพทย์, ผู้เข้ารับการฝึกอบรม

**ผลกระทบ:**
- 📚 กระจายความรู้การแพทย์ฉุกเฉินที่ถูกต้อง
- 💰 ลดค่าใช้จ่ายในการฝึกอบรม
- 🌟 จุดประกายวิชาชีพแพทย์/ผู้กู้ชีพ

### Section 7: Medical References
**แหล่งอ้างอิง:**
- NASEMSO National Model EMS Clinical Guidelines v2.2 (2019)
- BUMED (US Navy Bureau of Medicine and Surgery) — 18 handbooks
- AHA 2020 ACLS/BLS Guidelines

**QR Code:** (ถ้ามี — link ไปยัง demo video หรือ project page)

---

## Design Guidelines

### Color Palette Suggestion
- **Primary:** Deep Blue (#1a237e) — ความน่าเชื่อถือ, การแพทย์
- **Accent:** Emergency Red (#d32f2f) — ความเร่งด่วน
- **Success:** Teal/Green (#00897b) — สุขภาพ, ความสำเร็จ
- **Background:** White/Light Grey — clean, professional
- **Text:** Dark Grey (#212121) — readability

### Typography
- **Headers:** Bold sans-serif (Kanit, Noto Sans Thai, or similar)
- **Body:** Regular sans-serif
- **Tech/Code elements:** Monospace font

### Visual Style
- Clean, medical/professional aesthetic — NOT gamey/cartoonish
- Use flat icons or simple illustrations for process steps
- Screenshots should have device mockup frames
- Architecture diagram should be clean with rounded corners and subtle shadows
- Sufficient whitespace — avoid cluttering

### Must-Have Visual Elements
1. ✅ Gameplay flow diagram (visual, not text)
2. ✅ At least 4 in-game screenshots
3. ✅ Technology architecture diagram
4. ✅ Scenario cards with difficulty stars
5. ✅ Team/university branding

### Nice-to-Have
- Video QR code
- Comparison table (AeroMedica vs. traditional training)
- Patient deterioration timeline graphic
- START Triage color-coded flowchart
