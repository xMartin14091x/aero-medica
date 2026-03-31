# AI Tools Contribution Disclosure

AeroMedica: Protocol Playground was developed by the Ollama Paramedic team. This document transparently discloses all AI tools used during development, their specific roles, and the boundaries of their contribution.

## Principle

All AI tools served as assistants under human direction. The team made every design decision, defined the architecture, created the medical content specifications, and verified all outputs. No AI tool operated autonomously.

## AI Tools Used

### 1. Ollama (llama3.1:8b) — In-Game AI

**Role:** Runtime game feature, not a development tool.

**What it does in the game:**
- Patient Dialogue: generates in-character patient responses based on pre-defined medical persona data (symptoms, history, vitals) embedded in scenario JSON files
- AI Reviewer: analyzes player telemetry (movement, timing, equipment usage, triage decisions) and generates personalized feedback after each scenario

**Why Ollama:** Runs 100% offline on the local machine. No cloud API dependency. Patient data never leaves the device. This was a deliberate design choice for data privacy and deployment in institutions without reliable internet.

**Fallback:** When Ollama is unavailable, the game uses 70 pre-generated cached reviews (35 Thai + 35 English across 7 scenario/tier combinations) and scripted dialogue responses. The game is fully functional without Ollama.

### 2. Claude Code (Anthropic Claude Opus 4.6) — Development Assistant

**Role:** Code writing assistant and documentation generator.

**What it helped with:**
- Writing GDScript code based on team-specified architecture and requirements
- Generating documentation (development logs, feature descriptions, installation guides)
- Code review and bug identification
- Structured planning via the RoundTable Framework (ticket management, phase dispatch)

**What it did NOT do:**
- Did not make architectural decisions (owned by the team lead)
- Did not design the medical protocols (verified by clinical reference)
- Did not create game assets (3D models, textures, audio)
- Did not design the UI/UX layout (team decision)
- Did not determine scenario content or patient data (team-authored JSON files, clinically reviewed)

**Verification:** Every code output was tested in-game by the team before acceptance. Every document was reviewed and corrected by the team before submission.

### 3. Google Gemini (Gemini 3.1 Pro) — Visual and Ideation Assistant

**Role:** Brainstorming helper and image generator.

**What it helped with:**
- Expanding initial team concepts into structured ideas during early brainstorming
- Generating the main menu banner image for the game
- Drafting poster layout and content for the competition infographic
- Text refinement for Thai-language presentation materials

**What it did NOT do:**
- Did not write any game code
- Did not create 3D models or in-game assets
- Did not design game mechanics or medical protocols
- Final poster content was reviewed and corrected by the team (theme, business model, accuracy)

## Human Contributions (Team)

The following were done entirely by the human team:

- **Architecture design:** 6-layer system architecture, autoload structure, data flow design
- **Medical protocol design:** DRSABCDE assessment flow, triage algorithm, drug dosages, deterioration system, all verified against EMS standards
- **Scenario authoring:** All 5 scenario JSON files with 13 patients, each with unique vitals, examination findings (EN + TH), and clinically-accurate per-patient differential diagnoses
- **Game design:** Gameplay loop, 4-panel UI concept, scoring axes, difficulty progression
- **3D scene design:** Map layouts, Kenney asset placement, camera positioning
- **Testing:** End-to-end playtesting of all scenarios, QA bug reporting, medical accuracy verification
- **Business model:** B2B strategy targeting hospitals and EMT training institutions
- **Pitch and presentation:** Script writing, poster design direction, booklet content

## 3D Assets

- **Kenney low-poly kits** (CC0 license): Cars, commercial buildings, industrial buildings, suburban buildings, road props
- **Custom models:** Player character, patient models (Mixamo pipeline planned for v2)
- **Textures:** Ground tiles, UI elements — team-sourced

## Open Source

The project source code is available at: github.com/xMartin14091x/aero-medica (branch: ui-revamp-v2)

## Summary

| Tool | Category | Contribution |
|------|----------|-------------|
| Ollama llama3.1:8b | In-game AI | Patient dialogue + AI reviewer (runtime feature) |
| Claude Opus 4.6 | Dev assistant | Code writing + documentation (under team direction) |
| Gemini 2.5 Pro | Visual/ideation | Banner image + poster draft + brainstorming |
| Human team | Everything else | Architecture, medical protocols, game design, scenarios, testing, business model |
