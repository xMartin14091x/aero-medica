# ARC-02 — History Taking Dialogue UI

**Phase:** Phase 1 — Patient History Taking
**Team:** Arcade — Frontend/Creative
**Status:** `[x] Complete`
**Depends on:** None (scaffold with mocks, wire to MON-04 when ready)
**Blocks:** None

---

## Scope

Create the main dialogue panel UI that frames the history-taking interaction. This is the container that opens when the player begins taking a patient's history — it holds the SAMPLE category buttons (ARC-03) and the response display area (ARC-04).

## Implementation

### Create HistoryDialoguePanel Scene

New scene: `scenes/ui/hud/HistoryDialoguePanel.tscn`

**Layout:**
```
HistoryDialoguePanel (PanelContainer)
├── VBoxContainer
│   ├── HeaderLabel ("Patient History — [Patient Name]")
│   ├── HSeparator
│   ├── HBoxContainer (main content)
│   │   ├── CategoryButtonsPanel (left side — ARC-03 places buttons here)
│   │   └── ResponseDisplayPanel (right side — ARC-04 places responses here)
│   ├── HSeparator
│   └── HBoxContainer (footer)
│       ├── Label ("Press ESC or Q to close")
│       └── CloseButton ("Close History")
```

**Visual Style:**
- Semi-transparent dark background (matches existing UI theme from ThemeManager)
- Covers ~60% of screen (centered), leaving game world visible around edges
- Clean medical/professional aesthetic — no cartoon elements

### Create HistoryDialoguePanel Script

New file: `scripts/ui/history_dialogue_panel.gd`

```gdscript
extends PanelContainer

signal panel_closed

var _patient_name: String = ""

func open_panel(patient: Node) -> void:
    _patient_name = patient.name
    $VBoxContainer/HeaderLabel.text = "Patient History — %s" % _patient_name
    visible = true
    # Pause player input (prevent walking during dialogue)

func close_panel() -> void:
    visible = false
    panel_closed.emit()

func _unhandled_input(event: InputEvent) -> void:
    if not visible:
        return
    if event.is_action_pressed("ui_cancel") or event.is_action_pressed("drop"):
        close_panel()
```

### Wire in HUDController

Modify `hud_controller.gd`:
- Connect `HistoryTakingManager.history_started` → `HistoryDialoguePanel.open_panel()`
- Connect `HistoryTakingManager.history_ended` → `HistoryDialoguePanel.close_panel()`
- Connect `HistoryDialoguePanel.panel_closed` → `HistoryTakingManager.end_history()`

## Files to Create

- `scenes/ui/hud/HistoryDialoguePanel.tscn`
- `scripts/ui/history_dialogue_panel.gd`

## Files to Modify

- `scripts/ui/hud_controller.gd` — Wire history signals to dialogue panel
- `scenes/ui/hud/GameHUD.tscn` — Add HistoryDialoguePanel instance

## Acceptance Criteria

- [x] Panel opens when history taking begins on a patient
- [x] Patient name displays in header
- [x] Panel closes on ESC, Q, or Close button
- [x] Panel covers ~60% of screen, centered
- [x] Player movement is paused while panel is open
- [x] Panel does not conflict with ActionMenu or other UI

## Boundaries — Do NOT Touch

- Do NOT implement category buttons (ARC-03 does that)
- Do NOT implement response display (ARC-04 does that)
- Do NOT modify InteractionManager or AssessmentManager
