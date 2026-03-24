# ARC-04 — Patient Response Display & Animation

**Phase:** Phase 1 — Patient History Taking
**Team:** Arcade — Frontend/Creative
**Status:** `[x] Complete`
**Depends on:** None (scaffold with mocks, wire to MON-04 when ready)
**Blocks:** None

---

## Scope

Create the right-side panel of the history dialogue that displays patient responses as a scrolling conversation log. Each question-answer pair appears as a chat-style entry with typewriter text animation.

## Implementation

### Create ResponseDisplayPanel

New file: `scripts/ui/response_display_panel.gd`

**Visual Design:**
```
ResponseDisplayPanel (ScrollContainer)
└── VBoxContainer (conversation log)
    ├── Entry 1: [Q] "What happened?"
    │             [A] "I was crossing the road and a car hit me..."
    ├── Entry 2: [Q] "Where does it hurt?"
    │             [A] "My left leg... it hurts so much..."
    └── (auto-scrolls to latest entry)
```

**Entry Format:**
- Question line: Bold, left-aligned, prefixed with "You:" or "Q:"
- Response line: Normal weight, left-aligned, prefixed with patient name, indented slightly
- Unresponsive patients: Response in italic grey ("Patient is unresponsive.")
- Typewriter effect: Response text reveals character by character (~30 chars/sec)

### Script Implementation

```gdscript
extends ScrollContainer

var _log_container: VBoxContainer
var _typewriter_tween: Tween

func _ready() -> void:
    _log_container = $VBoxContainer

func add_exchange(question_label: String, response: String, patient_name: String) -> void:
    # Question label
    var q_label := RichTextLabel.new()
    q_label.bbcode_enabled = true
    q_label.fit_content = true
    q_label.text = "[b]You:[/b] \"%s\"" % question_label
    _log_container.add_child(q_label)

    # Response label with typewriter
    var r_label := RichTextLabel.new()
    r_label.bbcode_enabled = true
    r_label.fit_content = true
    var is_unresponsive := response == "Patient is unresponsive."
    if is_unresponsive:
        r_label.text = "[i][color=#888888]%s[/color][/i]" % response
    else:
        r_label.text = "[b]%s:[/b] \"%s\"" % [patient_name, response]

    _log_container.add_child(r_label)

    # Typewriter animation
    r_label.visible_ratio = 0.0
    if _typewriter_tween and _typewriter_tween.is_valid():
        _typewriter_tween.kill()
    _typewriter_tween = create_tween()
    var duration := response.length() / 30.0  # ~30 chars/sec
    _typewriter_tween.tween_property(r_label, "visible_ratio", 1.0, duration)

    # Spacer
    var spacer := Control.new()
    spacer.custom_minimum_size = Vector2(0, 8)
    _log_container.add_child(spacer)

    # Auto-scroll to bottom
    await get_tree().process_frame
    scroll_vertical = get_v_scroll_bar().max_value

func clear_log() -> void:
    for child in _log_container.get_children():
        child.queue_free()
```

### Wire in HistoryDialoguePanel

Connect signals:
- `CategoryQuestionsPanel.question_selected` → `HistoryTakingManager.ask_question()` → `response_received` → `ResponseDisplayPanel.add_exchange()`

## Files to Create

- `scripts/ui/response_display_panel.gd`

## Files to Modify

- `scenes/ui/hud/HistoryDialoguePanel.tscn` — Add ResponseDisplayPanel to right side
- `scripts/ui/history_dialogue_panel.gd` — Wire question_selected to ask_question and response display

## Acceptance Criteria

- [x] Question-answer pairs display in conversation log format
- [x] Typewriter animation reveals response text character by character
- [x] Scroll container auto-scrolls to latest entry
- [x] Unresponsive patient responses show in grey italic
- [x] Multiple exchanges display correctly in sequence
- [x] Log clears when dialogue panel closes and reopens on different patient

## Boundaries — Do NOT Touch

- Do NOT modify HistoryTakingManager logic
- Do NOT modify CategoryQuestionsPanel behavior
- Do NOT modify patient data or medical state
