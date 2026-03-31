# AeroMedica: Protocol Playground -- Pitch Deck Slide Guide

**Document Type:** Poster / Presentation Information
**Total Slides:** 16
**Team:** Ollama Paramedic
**Competition:** TMH 2026

---

## Slide 1 -- Title

**Headline:** AeroMedica: Protocol Playground
**Subtitle:** EMT 3D Training Simulator

**Visual Description:**
Full-screen title card with AeroMedica logo centered. Navy background with blue accent line. Team name and competition badge at bottom.

**Content:**
- AeroMedica: Protocol Playground
- EMT 3D Training Simulator
- Team: Ollama Paramedic
- TMH 2026

**Speaker Notes:**
Open strong. Introduce the project name and team. "We are Ollama Paramedic, and today we present AeroMedica -- a 3D training simulator built to keep emergency medical personnel sharp between real-world calls."

---

## Slide 2 -- Problem

**Headline:** The Skill Decay Crisis

**Visual Description:**
Declining graph showing skill retention over time. Two data callouts highlighted: 61% at 2 years and 14% at 12 months. Dark background with red accent on the decline curve.

**Content:**
- 61% skill degradation within 2 years of certification (Stept & Stross, 1980)
- ACLS pass rate drops to just 14% at 12 months post-training (Smith et al., 2008)
- Rarely-encountered cases accelerate skill decay fastest
- Current retraining is expensive and limited to physical training centers

**Speaker Notes:**
Set the urgency. "Research shows that within two years, EMTs lose over 60% of their procedural skills. For advanced cardiac life support, the pass rate collapses to 14% in just one year. The cases that matter most -- the rare, critical ones -- are exactly the skills that decay fastest. And right now, the only solution is expensive, location-bound retraining."

---

## Slide 3 -- Solution / Vision

**Headline:** A Supplementary Self-Training Tool

**Visual Description:**
Split panel: left side shows a traditional training center (expensive, limited), right side shows AeroMedica running on a laptop (accessible, anywhere). Arrow connecting the two with "supplement" label.

**Content:**
- Supplementary self-training tool for medical personnel
- AI-powered feedback via silent telemetry -- no manual grading needed
- 100% offline operation -- reduces cost and removes location barriers
- Not a replacement for real training -- a supplement to reinforce and maintain skills

**Speaker Notes:**
"AeroMedica is not here to replace instructors or mannequin labs. It is a supplement -- a tool that medical personnel can use on their own time, on their own device, anywhere. The AI runs entirely offline. No internet, no cloud, no patient data leaving the device."

---

## Slide 4 -- Gameplay Overview

**Headline:** How It Works

**Visual Description:**
4-step flow diagram: Spawn into scenario -> Walk to patient -> Assess and treat -> Receive AI feedback. Below the flow, a screenshot of the 3D isometric game view showing a scene with patients and the timer.

**Content:**
- Player spawns into a 3D scenario environment
- Walk to patient, begin assessment and treatment
- Time pressure: patients deteriorate in real-time
- 3D isometric camera view throughout gameplay

**Speaker Notes:**
"The gameplay loop is straightforward. You spawn into a scenario, approach your patient, and begin working through your assessment and treatment. But time is not on your side -- patients deteriorate in real-time. Delay too long, and the patient's condition worsens. This mirrors the pressure of real emergency response."

---

## Slide 5 -- 4 Gameplay Panels (Core Slide)

**Headline:** Four Panels, One Patient

**Visual Description:**
2x2 grid showing screenshots of each panel: Talk (dialogue), Examine (vitals/exam), Treat (medical bag/drugs), Diagnose (condition list). Each panel labeled clearly. This is the most content-dense slide -- allocate 60-90 seconds.

**Content:**

### Talk
- Ollama AI-powered patient dialogue
- Social skills training -- communicate with the patient naturally
- Unique feature: no similar training game offers AI patient conversation

### Examine
- DRSABCDE assessment: 8 systematic steps
- Vital Signs: 8 values (HR, BP, SpO2, RR, Temp, Pain, Pupil, Skin)
- ECG: 7 cardiac rhythms
- GCS scoring
- Head-to-Toe examination: 7 body regions

### Treat
- Medical Bag: BLS and ALS equipment
- Drug administration with route and dosage selection
- CPR + AED with ROSC logic

### Diagnose
- 47 conditions across 8 clinical categories
- Per-patient differential diagnosis (DDx) -- clinically verified

**Speaker Notes:**
"This is the heart of AeroMedica. Four panels give you everything you need to manage a patient. Talk lets you communicate with an AI patient -- this is something no similar training game offers. Examine walks you through DRSABCDE, vitals, ECG, GCS, and a full head-to-toe. Treat gives you BLS and ALS equipment, drug administration with real dosages, and CPR with AED including return-of-spontaneous-circulation logic. And Diagnose presents 47 real conditions -- each patient has their own clinically verified differential diagnosis."

---

## Slide 6 -- AI System

**Headline:** Offline AI -- Privacy by Design

**Visual Description:**
Architecture diagram: Ollama box (local device) connected to Game Engine. Two paths shown: live AI path (Ollama -> patient dialogue + AI reviewer) and fallback path (cached files). Status notification mockup showing "Ollama not found" message.

**Content:**
- Ollama llama3.1:8b runs entirely offline -- patient data never leaves the device
- Patient dialogue generated from PatientPersona data
- AI Reviewer: silent telemetry -> 5-axis scoring -> personalized feedback
- Cached fallback system: 70 pre-generated files (7 scenarios x 5 performance tiers x 2 languages) when Ollama is offline
- Game notifies the player when Ollama is not detected

**Speaker Notes:**
"Our AI runs on Ollama's llama3.1 8-billion parameter model, entirely on the local machine. No internet required, no data leaves the device. The AI powers two things: patient dialogue and the post-scenario reviewer that scores your performance across five axes. If Ollama is not installed, the game falls back to 70 pre-cached feedback files covering every scenario and performance tier in both Thai and English. The player always gets feedback."

---

## Slide 7 -- 5 Scenarios

**Headline:** Five Scenarios, Thirteen Patients

**Visual Description:**
Table or card layout showing each scenario with difficulty stars, patient count, and time limit. Color-coded by difficulty. Below the table, a deterioration flowchart: CONSCIOUS -> UNCONSCIOUS -> CARDIAC_ARREST -> DEAD.

**Content:**

| Scenario | Patients | Time Limit | Difficulty |
|----------|----------|------------|------------|
| Tutorial | 1 | Unlimited | 1/5 |
| Road Traffic Accident (RTA) | 3 | 15 min | 3/5 |
| Cardiac Arrest | 1 | 8 min | 2/5 |
| Mass Casualty Incident (MCI) | 6 + 1 random | 20 min | 5/5 |
| Building Fire | 1 | 9 min | 2/5 |

- 13 patients total, each with unique vitals, examination findings, and per-patient DDx
- Deterioration system: CONSCIOUS -> UNCONSCIOUS -> CARDIAC_ARREST -> DEAD

**Speaker Notes:**
"We built five scenarios with thirteen total patients. The tutorial eases you in with unlimited time. Then the difficulty ramps -- the RTA gives you three patients in fifteen minutes, cardiac arrest is a focused eight-minute race, the MCI throws seven patients at you in twenty minutes at maximum difficulty, and the building fire tests your prioritization with a nine-minute window. Every patient has unique vitals and findings. And if you take too long, patients deteriorate through four states -- from conscious all the way to dead."

---

## Slide 8 -- Medical Accuracy

**Headline:** Built on Real Protocols

**Visual Description:**
Protocol badges/icons: DRSABCDE, START Triage, ACLS/BLS, ECG, GCS. Example callout box showing an RTA patient with specific injuries and matching DDx. Clinical review stamp or seal graphic.

**Content:**
- DRSABCDE assessment per EMS standards
- START Triage classification (GREEN / YELLOW / RED / BLACK)
- Drug dosages follow ACLS/BLS protocols
- 7 ECG rhythms, GCS scoring
- Per-patient DDx: 47 conditions across 8 categories, clinically reviewed
- Example: RTA scenario -- 3 patients each have different diagnoses matching their specific injury patterns

**Speaker Notes:**
"Medical accuracy is non-negotiable. Our assessment follows DRSABCDE. Triage uses the START algorithm. Drug dosages match ACLS and BLS protocols. ECG rhythms and GCS scoring are implemented correctly. Every patient's differential diagnosis was clinically reviewed. For example, in the RTA scenario, each of the three patients has a different diagnosis that matches their specific injuries -- not a generic label."

---

## Slide 9 -- Scoring and Dashboard

**Headline:** Measure, Track, Improve

**Visual Description:**
Screenshot of the dashboard UI showing: radar chart with 5 axes, two tabs (My Performance / By Scenario), line chart showing score progression over time. Export button visible.

**Content:**
- 5-axis radar chart: Triage Speed, Protocol Accuracy, Decision Quality, Equipment Handling, Patient Outcome
- 2 dashboard tabs: My Performance + By Scenario
- Line chart showing score progression over time
- CSV/JSON data export for external analysis
- Dashboard updates immediately after scenario completion

**Speaker Notes:**
"After every scenario, you get scored across five axes on a radar chart -- triage speed, protocol accuracy, decision quality, equipment handling, and patient outcome. The dashboard has two views: your overall performance and per-scenario breakdowns. A line chart tracks your improvement over time. And you can export all your data as CSV or JSON for further analysis or instructor review."

---

## Slide 10 -- Comparison Table

**Headline:** AeroMedica vs. Traditional Training

**Visual Description:**
Clean comparison table, three rows. AeroMedica column highlighted in blue. Traditional training column in neutral gray.

**Content:**

| Dimension | AeroMedica | Traditional Training |
|-----------|------------|---------------------|
| Realism | 3D interactive environment + AI patient dialogue | Static textbooks and limited mannequin time |
| Assessment | AI-powered instant feedback, 5-axis scoring | Manual instructor evaluation, scheduling required |
| Access | Offline, run anywhere, no cost per session | Training center only, travel and facility costs |

**Speaker Notes:**
"Here is the comparison. Traditional training relies on static materials and expensive mannequin sessions that require scheduling and travel. AeroMedica gives you a 3D interactive environment with AI dialogue, instant automated feedback, and zero cost per session. You can train anywhere, anytime, offline."

---

## Slide 11 -- Tech Stack

**Headline:** Open Source, Zero License Cost

**Visual Description:**
Tech stack logos arranged in a clean grid: Godot, Ollama, JSON, Git/GitHub, Kenney. AI tools disclosure badge at bottom.

**Content:**
- Godot 4.6 -- open source game engine, no license fee
- Ollama llama3.1:8b -- offline AI, open source
- JSON data files, CSV translations (300+ keys, Thai/English)
- Git + GitHub for version control
- Kenney CC0 assets (Creative Commons Zero -- free to use)
- AI development tools: Claude Code + Gemini (disclosed in CONTRIBUTION.md)

**Speaker Notes:**
"Our entire stack is open source. Godot has no license fee. Ollama runs the AI locally at no cost. Game data is stored in JSON with CSV-based translations supporting over 300 keys in Thai and English. We use Kenney's CC0 assets. And we are transparent about our AI-assisted development -- Claude Code and Gemini usage is fully disclosed in our CONTRIBUTION.md file."

---

## Slide 12 -- Business Model (B2B)

**Headline:** Who Benefits

**Visual Description:**
Three target segments shown as cards or columns: Hospitals, EMT Training Institutions, Medical Schools. Each with an icon and 1-2 benefit bullets. Bottom banner with the cost-reduction message.

**Content:**

### Hospitals
- Retrain ER staff on-site
- Reduce mannequin and instructor costs

### EMT Training Institutions / Medical Schools
- Supplementary practical learning tool
- Unlimited student practice -- no scheduling bottleneck

### Bottom Line
- Reduce training costs
- Provide a safe learning environment with zero patient risk
- Distribute training access nationwide

**Speaker Notes:**
"The business case is B2B. Hospitals can use AeroMedica to retrain ER staff without the cost of mannequins and dedicated instructors. Medical schools and EMT training institutions get a supplementary tool that lets students practice unlimited times without scheduling constraints. The bottom line: reduced costs, safe environment, and training access that can scale nationwide."

---

## Slide 13 -- Future: Instructor Web Dashboard

**Headline:** What Comes Next -- Instructor Dashboard

**Visual Description:**
Mockup or wireframe of a browser-based dashboard showing: student list with real-time status, individual radar charts, class-wide statistics panel. LAN connection diagram showing game clients connecting to local server.

**Content:**
- Browser-based LAN dashboard for instructors
- Real-time student monitoring with individual radar charts and class statistics
- FastAPI + SQLite + WebSocket architecture
- Offline queue: game stores data locally, auto-syncs when reconnected
- 8 tickets planned and approved for implementation

**Speaker Notes:**
"Our next phase is an instructor web dashboard. It runs on the local network -- no cloud required. Instructors can monitor students in real-time, see individual radar charts, and view class-wide statistics. The architecture uses FastAPI, SQLite, and WebSocket. If the connection drops, the game queues data locally and syncs automatically when reconnected. We have eight tickets planned and approved for this feature."

---

## Slide 14 -- Prototype Results

**Headline:** What We Built

**Visual Description:**
Key metrics displayed as large numbers with labels: 22 days, 72 sessions, 13 patients, 5 scenarios, 22+ bugs fixed. GitHub badge or open source icon.

**Content:**
- 22 days of development
- 72 logged development sessions
- 13 patients across 5 scenarios
- 22+ bugs found and fixed, end-to-end tested
- Per-patient differential diagnosis clinically verified
- Open source -- published on GitHub

**Speaker Notes:**
"In 22 days and 72 development sessions, we built a working prototype with 13 patients across 5 scenarios. We found and fixed over 22 bugs through end-to-end testing. Every patient's differential diagnosis was clinically verified. And the entire project is open source on GitHub."

---

## Slide 15 -- QR Code / Demo

**Headline:** Try It Yourself

**Visual Description:**
Two large QR codes side by side: left QR links to GitHub repository, right QR links to Google Drive download. Below the QR codes, step-by-step instructions in large readable text.

**Content:**
- QR Code 1: GitHub Repository
- QR Code 2: Google Drive Download
- Instructions:
  1. Download the archive
  2. Extract the folder
  3. Run AeroMedica.exe
- Optional: Install Ollama for full AI features (patient dialogue + AI reviewer)

**Speaker Notes:**
"We want you to try it. Scan the left QR code for our GitHub repo, or the right one for a direct download from Google Drive. Download, extract, and run AeroMedica.exe -- that is all it takes. If you want the full AI experience with patient dialogue and the AI reviewer, install Ollama separately. The game works without it using cached feedback."

---

## Slide 16 -- Closing

**Headline:** More Than a Game

**Visual Description:**
Dark navy background, centered quote in large white text. Team name and contact information at bottom. Subtle medical cross or heartbeat line graphic.

**Content:**
- "AeroMedica is not just a game. This is a tool for society to improve healthcare through technology integration."
- Lives saved through better preparedness
- Thank you
- Team: Ollama Paramedic
- Competition: TMH 2026

**Speaker Notes:**
"We will leave you with this. AeroMedica is not just a game. This is a tool for society -- a way to improve healthcare through technology integration. Every hour of practice in this simulator is an hour of preparedness that could save a real life. Thank you. We are Ollama Paramedic."

---

## Design Guidelines

| Element | Specification |
|---------|--------------|
| Background color | Navy blue (#0A1628) |
| Highlight / accent color | Blue (#2E86DE) |
| Text color | White |
| Font | Kanit (Thai-readable) |
| Visual assets | Use actual in-game screenshots wherever possible |
| Content density | Maximum 5 bullet points per slide |
| Layout | Consistent structure across all 16 slides |
| Language | Thai primary, English terms where standard (DRSABCDE, START, ACLS, BLS, GCS, DDx) |
