# ARC-20 — Full Audio System

**Phase:** Phase 6 — Content Expansion
**Team:** Arcade — Frontend/Creative
**Status:** `[x] Complete`
**Depends on:** ARC-10 (Phase 4 hazard audio foundation)
**Blocks:** None

---

## Scope
Implement the complete audio system — ambient soundscapes, UI feedback sounds, patient audio cues, and background music for all scenarios.

## Acceptance Criteria
- [x] **Ambient soundscapes** per environment (5 AmbientType enum values, procedural AudioStreamWAV 8-bit 22050Hz):
  - TUTORIAL_PARK: light noise + random high-freq bird chirps
  - RTA_TRAFFIC: 60Hz drone + intermittent horn blasts
  - CARDIAC_INDOOR: quiet room tone + clock tick every ~1 second
  - MCI_CROWD: chaotic noise + modulating siren (600Hz +/- 200Hz)
  - FIRE_ALARM: 30Hz rumble + alarm beep every 2 seconds + crackling noise
- [x] **UI feedback sounds:** click (800Hz), pickup (400Hz), confirm (C5->E5 ascending two-tone), error (300Hz descending + dissonant harmonic), triage tag (660Hz)
- [x] **Patient audio cues:** groan (120Hz + vibrato + intermittent envelope, looping), breathing (inhale/pause/exhale/pause 3s cycle, looping), silence for cardiac arrest/dead
- [x] **Background music:** CALM (C3+G3+E3 pad with slow volume modulation), MEDIUM (220Hz + 1Hz pulse), HIGH/CRITICAL (BPM-driven beat 140/170 + Bb3+Db4 dissonant)
- [x] Dynamic music system: 3-layer crossfade via parallel Tween (1.5s fade), layers play simultaneously with volume control
- [x] Master volume, music volume, SFX volume, ambient volume — individual dB controls via setter methods
- [x] All audio procedurally generated (AudioStreamWAV FORMAT_8_BITS) — no external files required
- [x] Test: AudioSystem node added to HUD.tscn, auto-wires to TimePressureSystem/ScenarioManager/AssessmentManager/TriageSystem, each level calls set_ambient()

## Boundaries — Do NOT Touch
- Do NOT implement voice acting or TTS — F12 scope handles AI-generated speech
- Do NOT implement 3D spatial audio for music — only for environmental SFX and patient cues

## Notes
- Audio sources: [Freesound.org](https://freesound.org/), [Pixabay Audio](https://pixabay.com/sound-effects/), [Zapsplat](https://www.zapsplat.com/) (free with attribution)
- File formats: .ogg for music/ambience, .wav for short SFX
