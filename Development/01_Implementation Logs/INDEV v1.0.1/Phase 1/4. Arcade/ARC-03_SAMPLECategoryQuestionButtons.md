# ARC-03 — SAMPLE Category Question Buttons

**Phase:** Phase 1 — Patient History Taking
**Team:** Arcade — Frontend/Creative
**Status:** `[x] Complete`
**Depends on:** None (scaffold with mocks, wire to MON-04 when ready)
**Blocks:** None

---

## Scope

Create the left-side panel of the history dialogue that displays SAMPLE category buttons and per-category question lists. Player selects a category (S/A/M/P/L/E), sees available questions, and clicks one to ask the patient.

## Implementation

### Two-Level Navigation

**Level 1 — Category Selection:**
Six buttons, one per SAMPLE letter:
| Key | Button Label | Shortcut |
|-----|-------------|----------|
| 1 | S — Symptoms | 1 |
| 2 | A — Allergies | 2 |
| 3 | M — Medications | 3 |
| 4 | P — Past History | 4 |
| 5 | L — Last Meal | 5 |
| 6 | E — Events | 6 |

**Level 2 — Question Selection:**
When a category is selected, show its questions as clickable buttons. Already-asked questions are greyed out with a checkmark.

### Create CategoryQuestionsPanel

New file: `scripts/ui/category_questions_panel.gd`

```gdscript
extends VBoxContainer

signal question_selected(category: String, question_key: String)

var _current_category: String = ""
var _question_data: Dictionary = {}  # From HistoryTakingManager
var _asked_tracker: Callable  # Function to check if question was asked

func set_question_data(data: Dictionary) -> void:
    _question_data = data
    _show_categories()

func set_asked_checker(checker: Callable) -> void:
    _asked_tracker = checker

func _show_categories() -> void:
    _clear_children()
    _current_category = ""
    var categories := [
        ["symptoms", "S — Symptoms"],
        ["allergies", "A — Allergies"],
        ["medications", "M — Medications"],
        ["past_history", "P — Past History"],
        ["last_meal", "L — Last Meal"],
        ["events", "E — Events"],
    ]
    for i in range(categories.size()):
        var btn := Button.new()
        btn.text = "%d. %s" % [i + 1, categories[i][1]]
        var cat: String = categories[i][0]
        btn.pressed.connect(_on_category_pressed.bind(cat))
        add_child(btn)

func _on_category_pressed(category: String) -> void:
    _current_category = category
    _show_questions(category)

func _show_questions(category: String) -> void:
    _clear_children()
    # Back button
    var back := Button.new()
    back.text = "← Back to Categories"
    back.pressed.connect(_show_categories)
    add_child(back)
    # Question buttons
    var questions: Array = _question_data.get(category, [])
    for q in questions:
        var btn := Button.new()
        var key: String = q.get("key", "")
        var label: String = q.get("label", "")
        var asked := _asked_tracker.call(category, key) if _asked_tracker.is_valid() else false
        btn.text = ("✓ " if asked else "") + label
        btn.disabled = asked
        btn.pressed.connect(func(): question_selected.emit(category, key))
        add_child(btn)

func _clear_children() -> void:
    for child in get_children():
        child.queue_free()

func _unhandled_input(event: InputEvent) -> void:
    # Number key shortcuts for categories
    if _current_category.is_empty():
        for i in range(1, 7):
            if event.is_action_pressed("ui_%d" % i):
                # Map 1-6 to categories
                pass  # Wire in implementation
```

## Files to Create

- `scripts/ui/category_questions_panel.gd`

## Files to Modify

- `scenes/ui/hud/HistoryDialoguePanel.tscn` — Add CategoryQuestionsPanel to left side

## Acceptance Criteria

- [x] Six SAMPLE category buttons display on panel open
- [x] Clicking a category shows its available questions
- [x] Back button returns to category view
- [x] Asked questions show checkmark and are greyed out/disabled
- [x] Clicking a question emits `question_selected` signal
- [x] Number keys 1-6 work as shortcuts for categories

## Boundaries — Do NOT Touch

- Do NOT implement the response display (ARC-04)
- Do NOT modify HistoryTakingManager logic
- Do NOT modify patient data or persona
