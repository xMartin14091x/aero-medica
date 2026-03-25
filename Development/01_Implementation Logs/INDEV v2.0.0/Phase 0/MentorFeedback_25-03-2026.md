# INDEV v2.0.0 — Mentor Feedback & Planned Features

**Date:** 25-03-2026
**Source:** Mentor review session (competition presentation feedback)
**Status:** PLANNED — deferred from v1.0.1 competition build

---

## Scope Direction: EMT-First

Mentor recommended narrowing target audience to **EMT/medical personnel** for v1.0. The current 47-item DDx list includes advanced medical terms (Cardiac Tamponade, Tension Pneumothorax, etc.) which are appropriate for EMT-level training but overwhelming for laypersons.

**v2.0 plan:** Add a "Normal People" mode as a separate game mode with:
- Simplified DDx options (10-15 common terms)
- Guided assessment flow (step-by-step prompts)
- Plain language explanations for medical terms
- Reduced scenario complexity

**Rationale:** Assure highest quality for professionals first. Simplification is easier than complexity — build expert mode, then derive beginner mode from it.

---

## MOD-v2-01 — Action Cooldown System

**Requested by:** Mentor
**Concept:** All assessment and treatment actions have realistic time delays with circular progress indicators. Prevents instant-spam of all assessments.

| Action Type | Proposed Delay | Max Concurrent |
|-------------|---------------|----------------|
| DRSABCDE assessments | 3-5 seconds | 1 at a time (sequential exam) |
| Vital sign readings | 2-4 seconds | Max 5 simultaneous |
| Equipment/tools (IV, O2, AED) | 5-8 seconds | Max 3 simultaneous |
| Drug administration | 8-10 seconds | 1 at a time |

**UI Design:**
- Circular progress ring overlaid on button face
- Button disabled during cooldown, ring fills clockwise
- Buttons grey out when max concurrent limit reached
- Audio tick or subtle pulse during progress
- Completion sound on finish

**Implementation Notes:**
- Add `CooldownManager` node attached to player
- Each action type has a cooldown group with max concurrent slots
- PatientInteractionUI buttons wire to CooldownManager before executing
- Progress ring is a custom `TextureProgressBar` or shader on the button

---

## MOD-v2-02 — Step-Up Timer Per Patient

**Requested by:** Mentor
**Concept:** Visible stopwatch per patient counting UP from 0:00 the moment you first interact with them. Creates time pressure — "You've spent 2:34 on this patient and haven't triaged yet." In multi-patient scenarios, seeing one patient at 4:12 and another at 0:00 drives urgency to move on.

**Display:**
- Patient interaction UI header: "Time on Patient: 2:34"
- Minimap patient icons: small timer label next to name
- Debrief screen: per-patient time spent breakdown
- Counts only while PatientInteractionUI is open for THAT patient (pauses when unfocused)

**Scoring Integration:**
- Time-per-patient feeds into the "Triage Speed" scoring axis
- AI reviewer receives per-patient time data and comments on over/under-attention
- Benchmark times per scenario (e.g., tutorial < 3 min, MCI < 2 min per patient)

---

## MOD-v2-03 — Normal People Game Mode

**Concept:** Simplified mode derived from the EMT-expert mode.

**Differences from EMT mode:**
- Guided step-by-step prompts ("Check if they're breathing" vs raw DRSABCDE buttons)
- Simplified DDx (10-15 options in plain language)
- Visual cues highlighting what to do next
- Longer time limits / slower deterioration
- Tooltip explanations for medical terms
- Achievement/tutorial system for learning progression

---

## MOD-v2-04 — Adverse Drug Effect Feedback

**Concept:** When a drug administration causes harm (wrong drug, wrong dose, wrong patient condition), the game should explicitly flag it rather than silently applying effects.

**Current behavior (v1.0.1):**
- Contraindication check blocks obvious mismatches (e.g., Atropine on tachycardia)
- Max dose enforcement prevents overdose past the defined ceiling
- But effects apply blindly if checks pass — no "you made this worse" feedback
- Example: 1mg Epi (max dose 10mg) given 10 times = 300 HR, +200 BP systolic — patient enters lethal tachycardia with no warning

**v2.0 plan — Consequence-Based Drug System:**

Two tiers of wrong drug administration:

**Tier 1 — Wrong but not contraindicated:** Drug effects apply honestly. Patient deteriorates appropriately from the applied effects. Recoverable if player corrects course. Example: unnecessary Morphine on a normotensive patient — BP drops, but manageable.

**Tier 2 — Contraindicated = death penalty:** Administering a drug flagged as contraindicated for the patient's current condition causes immediate lethal deterioration — cardiac arrest → death. No block, no popup, no "are you sure." The drug is given, the patient dies. Example: Atropine on SVT (contraindicated: Tachycardia) → HR spikes → VFib → dead.

**Implementation:**
- Remove the current contraindication BLOCK (which prevents administration)
- Replace with: contraindicated drug APPLIES but triggers rapid lethal cascade
- Drug effects still apply normally (Tier 1 path)
- If contraindication matched → additional lethal modifier applied on top (Tier 2 path)
- AI reviewer reports the drug error with full context in debrief
- Telemetry logs it as a critical medication error
- **Design principle:** Teach by consequence, not prevention

---

## MOD-v2-05 — Full UI/UX Overhaul

**Reported by:** Chief Manager Martin (live gameplay frustration)
**Priority:** CRITICAL for v2.0

**Current problems:**
- Text is clumped together with no breathing room — walls of data
- Font sizes too small for gameplay reading speed
- No visual hierarchy — vital signs, assessment results, drug info all look the same
- No color coding beyond triage tags — everything is white/grey text
- Buttons are plain unstyled rectangles with no visual weight
- Scrolling panels feel like spreadsheets, not a medical interface
- During time pressure, finding information is harder than the medicine itself

**v2.0 plan:**
- **Spacing & padding:** Generous margins between sections. Cards/panels with clear boundaries.
- **Typography scale:** Section headers 20-24px, body 16px, labels 14px. Bold for values, regular for labels.
- **Color system:** Vitals color-coded by severity (green/yellow/red). Equipment type-coded. Drug categories color-banded.
- **Card-based layout:** Each assessment result in its own card with icon + value + interpretation. Not a text dump.
- **Vital signs dashboard:** Dedicated panel with gauge-style displays or large number readouts, not inline text.
- **Drug administration:** Styled form with clear dropdowns, dose selector with visual units, confirmation feedback.
- **Responsive scaling:** UI scales properly at different resolutions.
- **Animation:** Subtle transitions on tab switch, result reveal, value changes. Pulse animation on critical values.
- **Theme system:** Dark medical theme with accent colors. Consistent across all panels.
- **Accessibility:** High contrast mode option. Minimum touch target sizes.

**Design principle:** The UI should be a tool that disappears during play — if the player is fighting the interface instead of treating the patient, the interface has failed.

### Implementation: Godot Theme + StyleBoxFlat (Option A — No Dependencies)

**Approach:** Custom Godot Theme resource with `StyleBoxFlat` for every control type. Modern dashboard aesthetic — dark background, card panels, colored accents, generous whitespace.

**Color Palette:**
```
Background:     #0F1117  (near-black)
Card surface:   #1A1D27  (dark slate)
Card border:    #2A2D3A  (subtle edge)
Card hover:     #22253A  (lift effect)
Text primary:   #E8EAF0  (bright white)
Text secondary: #8B8FA3  (muted grey)
Accent blue:    #4C9AFF  (selections, links)
Accent green:   #36B37E  (normal/good values)
Accent yellow:  #FFAB00  (warning values)
Accent red:     #FF5630  (critical/danger)
Accent purple:  #6554C0  (info/neutral)
```

**Card Design (StyleBoxFlat):**
```
corner_radius:     8px all corners
border_width:      1px
border_color:      #2A2D3A
bg_color:          #1A1D27
shadow_color:      #00000040
shadow_size:       4px
shadow_offset:     (0, 2)
content_margin:    16px all sides
```

**Button States:**
```
Normal:   bg #1A1D27, border #2A2D3A, text #E8EAF0, corner 6px
Hover:    bg #22253A, border #4C9AFF, text #FFFFFF
Pressed:  bg #4C9AFF, border #4C9AFF, text #FFFFFF
Disabled: bg #14161E, border #1E2030, text #555870
```

### Visual Examples — Tab by Tab

**EXAM TAB — Primary Survey (DRSABCDE)**
```
┌─────────────────────────────────────────────────────┐
│  PRIMARY SURVEY                              4/8 ✓  │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌──────────────┐  ┌──────────────┐                │
│  │ D            │  │ R            │                │
│  │ Danger       │  │ Response     │                │
│  │ ── ── ── ── │  │              │                │
│  │ ✓ Scene Safe │  │  ▶ Assess   │                │
│  └──────────────┘  └──────────────┘                │
│                                                     │
│  ┌──────────────┐  ┌──────────────┐                │
│  │ S            │  │ A            │                │
│  │ Send Help    │  │ Airway       │                │
│  │ ── ── ── ── │  │ ── ── ── ── │                │
│  │ ✓ Called EMS │  │ ⚠ OBSTRUCTED│                │
│  └──────────────┘  └──────────────┘                │
│                                                     │
│  ┌──────────────┐  ┌──────────────┐                │
│  │ B            │  │ C            │                │
│  │ Breathing    │  │ Circulation  │                │
│  │ ── ── ── ── │  │ ── ── ── ── │                │
│  │ RR: 28/min  │  │ Pulse: YES   │                │
│  │ SpO2: 88%   │  │ HR: 122 bpm  │                │
│  └──────────────┘  └──────────────┘                │
│                                                     │
│  ┌──────────────┐  ┌──────────────┐                │
│  │ D            │  │ E            │                │
│  │ Disability   │  │ Exposure     │                │
│  │              │  │              │                │
│  │  ▶ Assess   │  │  ▶ Assess   │                │
│  └──────────────┘  └──────────────┘                │
│                                                     │
└─────────────────────────────────────────────────────┘
```
- Each letter is a CARD, not a button
- Before assessment: shows letter + name + "Assess" action
- After assessment: result replaces the action, color-coded by severity
- Card border turns green (normal), yellow (abnormal), red (critical)

**EXAM TAB — Vital Signs Dashboard**
```
┌─────────────────────────────────────────────────────┐
│  VITAL SIGNS                                        │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ │
│  │ HR      │ │ BP      │ │ SpO2    │ │ Temp    │ │
│  │         │ │         │ │         │ │         │ │
│  │  122    │ │ 108/72  │ │   88%   │ │  37.1°  │ │
│  │   bpm   │ │  mmHg   │ │         │ │    C    │ │
│  │ ▲ TACHY │ │  NORMAL │ │ ▼ LOW   │ │ NORMAL  │ │
│  └─────────┘ └─────────┘ └─────────┘ └─────────┘ │
│   [yellow]    [green]     [red]       [green]      │
│                                                     │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ │
│  │ BGL     │ │ CRT     │ │ Pupils  │ │ Skin    │ │
│  │         │ │         │ │         │ │         │ │
│  │   95    │ │  2.2s   │ │ 3/3 mm  │ │ PALE    │ │
│  │  mg/dL  │ │         │ │ reactive│ │ COOL    │ │
│  │ NORMAL  │ │ NORMAL  │ │ EQUAL   │ │ DIAPH.  │ │
│  └─────────┘ └─────────┘ └─────────┘ └─────────┘ │
│   [green]     [green]     [green]     [yellow]     │
│                                                     │
└─────────────────────────────────────────────────────┘
```
- Large central number — the VALUE is the hero, not the label
- Color-coded card background tint per severity
- Requires equipment deployment first (card shows lock icon until deployed)
- Click to re-assess — value updates with subtle animation

**STABILIZE TAB — Equipment Bag (Single Source)**
```
┌─────────────────────────────────────────────────────┐
│  MEDICAL BAG — ALS                     CPR ● ACTIVE │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ── Diagnostic (deploy first to unlock vitals) ── │
│                                                     │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐           │
│  │ PulseOx  │ │ BP Cuff  │ │ Penlight │           │
│  │  [x1]    │ │  [x1]    │ │  [x1]    │           │
│  └──────────┘ └──────────┘ └──────────┘           │
│  ┌──────────┐ ┌──────────┐                         │
│  │ Thermo.  │ │ Glucom.  │                         │
│  │  [x1]    │ │  [x1]    │                         │
│  └──────────┘ └──────────┘                         │
│                                                     │
│  ── Treatment ──────────────────────────────────── │
│                                                     │
│  ┌────────────────────┐ ┌────────────────────┐     │
│  │ 🩹 Bandage    x3  │ │ 🔴 Tourniquet x2  │     │
│  │    [Deploy]       │ │    [Deploy]        │     │
│  └────────────────────┘ └────────────────────┘     │
│  ┌────────────────────┐ ┌────────────────────┐     │
│  │ 😮‍💨 O2 Mask    x2  │ │ 🫁 BVM        x1  │     │
│  │    [Deploy]       │ │    [Deploy]        │     │
│  └────────────────────┘ └────────────────────┘     │
│  ┌────────────────────┐ ┌────────────────────┐     │
│  │ ⚡ AED        x1  │ │ 💉 IV Access   x2  │     │
│  │    [Deploy]       │ │    [Deploy]        │     │
│  └────────────────────┘ └────────────────────┘     │
│                                                     │
│  ── Triage ──────────────────────────────────────  │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐              │
│  │ 🟢  │ │ 🟡  │ │ 🔴  │ │ ⬛  │              │
│  │GREEN │ │YELLOW│ │ RED  │ │BLACK │              │
│  └──────┘ └──────┘ └──────┘ └──────┘              │
│                                                     │
├─────────────────────────────────────────────────────┤
│  ── Drug Administration ──────────────────────────  │
│  Drug:  [Epinephrine 1:10,000 ▾]                   │
│  Route: [IV                    ▾]                   │
│  Dose:  [1 mg                  ▾]                   │
│         [  Administer  ]                            │
│                                                     │
│  Drug Log:                                          │
│  14:23  Epinephrine 1mg IV ✓                       │
│  14:25  Atropine 0.5mg IV ✓                        │
└─────────────────────────────────────────────────────┘
```
- NO duplicate equipment grid — bag is the single source
- Grouped: Diagnostic / Treatment / Triage / Drugs
- Quantity shown on each card — depletes visually
- Deployed items show checkmark, greyed out if exhausted

**DIFFERENTIAL TAB — Categorized + Searchable**
```
┌─────────────────────────────────────────────────────┐
│  DIFFERENTIAL DIAGNOSIS                             │
│  🔍 [Search diagnoses...              ]             │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ▼ Cardiac                                         │
│  ┌──────────────┐ ┌──────────────┐ ┌────────────┐ │
│  │Cardiac Arrest│ │    STEMI     │ │  NSTEMI    │ │
│  └──────────────┘ └──────────────┘ └────────────┘ │
│  ┌──────────────┐ ┌──────────────┐                 │
│  │  Vent. Fib   │ │Cardiac Tamp. │                 │
│  └──────────────┘ └──────────────┘                 │
│                                                     │
│  ▼ Respiratory                                     │
│  ┌──────────────┐ ┌──────────────┐ ┌────────────┐ │
│  │Resp. Failure │ │Tension Pneum.│ │Smoke Inhal.│ │
│  └──────────────┘ └──────────────┘ └────────────┘ │
│                                                     │
│  ▶ Trauma (collapsed)                              │
│  ▶ Neurological (collapsed)                        │
│  ▶ Other (collapsed)                               │
│                                                     │
├─────────────────────────────────────────────────────┤
│  Selected (2/3):                                    │
│  [1. Cardiac Arrest  ✕] [2. Vent. Fib  ✕]         │
│                                                     │
│         [ Submit Diagnosis ]                        │
└─────────────────────────────────────────────────────┘
```
- Collapsible categories — only expand what you need
- Search bar filters across all categories in real time
- Selected diagnoses shown as removable chips at bottom
- Max 3, ordered by priority (drag to reorder)

### Implementation Approach (Godot StyleBoxFlat)
```gdscript
# Example: create a card-style StyleBox
func _make_card_style(severity: String = "normal") -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = Color("#1A1D27")
    style.border_width_left = 1
    style.border_width_right = 1
    style.border_width_top = 1
    style.border_width_bottom = 1
    style.border_color = Color("#2A2D3A")
    style.corner_radius_top_left = 8
    style.corner_radius_top_right = 8
    style.corner_radius_bottom_left = 8
    style.corner_radius_bottom_right = 8
    style.content_margin_left = 16
    style.content_margin_right = 16
    style.content_margin_top = 12
    style.content_margin_bottom = 12
    style.shadow_color = Color(0, 0, 0, 0.25)
    style.shadow_size = 4
    style.shadow_offset = Vector2(0, 2)
    match severity:
        "warning": style.border_color = Color("#FFAB00")
        "critical": style.border_color = Color("#FF5630")
        "good": style.border_color = Color("#36B37E")
        "active": style.border_color = Color("#4C9AFF")
    return style
```

### Current Panel Audit & Redundancy Report

**Tab 1 — Patient (Chat + Info)**
- Patient info label (name, age, state) + AI status + chat scroll + input field + SAMPLE buttons
- **Issue:** Chat bubbles and patient info compete for space. No clear visual separation.
- **Redundancy:** None — clean.

**Tab 2 — Exam (DRSABCDE + Vitals + ECG + GCS + Secondary Survey)**
- 8 DRSABCDE buttons + 8 Vital Sign buttons + ECG panel + GCS selector + 7 Secondary Survey regions
- **Issue:** 23+ buttons + results all in one scrollable column. Massive wall of text. Results show as inline labels next to disabled buttons — no visual distinction between "not done" and "done."
- **Redundancy:** None functionally, but the SHEER DENSITY is the problem. Everything looks the same.

**Tab 3 — Stabilize (CPR + Equipment Grid + Bag Contents + Drug Admin + Triage)**
- CPR button + 14 equipment buttons (3-column grid) + Bag Contents scroll + Drug dropdowns (name/route/dose) + Administer button + Drug log + Triage Tags
- **Issue:** THIS IS THE WORST TAB. Three separate systems (equipment, drugs, triage) crammed into one scroll.
- **Redundancy found:**
  - Equipment grid has "O2 Mask" AND Bag Contents also lists "OXYGEN_MASK" — player can deploy from EITHER place, but they look different and behave differently (equipment grid = instant deploy, bag contents = quantity-tracked deploy)
  - "Bandage" in equipment grid AND "BANDAGE" in bag contents — same duplication
  - "AED" in equipment grid AND "AED" in bag contents
  - "Tourniquet", "Splint", "IV Access", "C-Collar" — ALL duplicated between equipment grid and bag contents
  - The equipment grid was the v1.0.0 system, bag contents was added in v1.0.1. Both survived.
  - Diagnostic equipment (Pulse Ox, BP Cuff, Penlight, Thermometer, Glucometer) appears in equipment grid AND bag contents
  - Triage Tags button is ALSO in bag contents — player can triage from either

**Tab 4 — Differential (DDx selection)**
- Instructions + 47 diagnosis buttons (6-column grid) + selected list + submit button
- **Issue:** 47 buttons is overwhelming. No categorization, no search, no filtering.
- **Redundancy:** None, but the FLAT LIST is the design failure.

### v2.0 Redesign Plan

**Tab 2 — Exam: Split into sub-panels**
- Primary Survey card (DRSABCDE) — large buttons, result appears INSIDE the button after press
- Vital Signs dashboard — separate panel with gauge-style readouts, not text labels
- ECG strip — dedicated card with large image + rhythm label below
- GCS — 3-slider component, not a grid of 15 buttons
- Secondary Survey — body diagram with clickable regions (head, neck, chest, etc.)

**Tab 3 — Stabilize: REMOVE EQUIPMENT GRID entirely**
- Keep ONLY Bag Contents as the single source of equipment deployment
- Bag Contents becomes the primary interface — cards with icon + name + quantity + deploy button
- Group into: Diagnostic Equipment / Treatment Equipment / Triage
- CPR stays as a prominent action above the bag
- Drug Admin gets its own sub-tab or accordion section
- Triage gets its own dedicated card, not buried in equipment list

**Tab 4 — Differential: Categorized + searchable**
- Group by system: Cardiac, Respiratory, Trauma, Neurological, etc.
- Collapsible categories, max 8-10 per category
- Search bar at top for quick filtering
- Selected diagnoses shown as chips/tags, drag to reorder priority

---

## MOD-v2-06 — AED Manual Rhythm Assessment

**Concept:** AED should NOT auto-shock on deployment. Instead:
1. Player deploys AED → pads attached, device powers on
2. AED displays: "Analysing rhythm..." (2-3 second delay)
3. Player presses "Assess Rhythm" button → AED reads ECG
4. If shockable: "Shock Advised — Press to Deliver" → player presses shock button
5. If non-shockable: "No Shock Advised — Continue CPR"

This models real AED behavior (semi-automatic). The player must actively decide to shock.
Current v1.0: deploy AED = auto-analyse + auto-shock. v2.0 adds manual steps.

---

## Notes

- These features are deferred to post-competition. v1.0.1 ships with current EMT-level gameplay.
- Cooldown system is highest priority for v2.0 (most impact on realism).
- Step counter is second priority (visible progress tracking).
- Normal People mode is a full design effort — requires its own planning phase.
- Mentor's overall assessment: "Ideas are golden and really well executed."
