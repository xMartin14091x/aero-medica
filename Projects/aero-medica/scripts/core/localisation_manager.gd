## LocalisationManager — Handles language switching and translation loading.
## Loads translations from CSV, provides tr() wrapper, emits locale_changed.
extends Node

signal locale_changed(locale: String)

## Supported locales.
const LOCALE_TH := "th"
const LOCALE_EN := "en"

## Current locale.
var current_locale: String = LOCALE_TH

## Translation data loaded from CSV.
var _translations: Dictionary = {}


func _ready() -> void:
	_load_translations()
	_apply_locale(current_locale)


func _load_translations() -> void:
	var file := FileAccess.open("res://data/translations/translations.csv", FileAccess.READ)
	if not file:
		push_warning("LocalisationManager: Could not open translations.csv")
		return

	# Parse header
	var header := file.get_csv_line()
	if header.size() < 3:
		push_warning("LocalisationManager: Invalid CSV header")
		return

	# Find column indices
	var th_col := -1
	var en_col := -1
	for i in header.size():
		var col := header[i].strip_edges().to_lower()
		if col == "th":
			th_col = i
		elif col == "en":
			en_col = i

	if th_col == -1 or en_col == -1:
		push_warning("LocalisationManager: Missing 'th' or 'en' column")
		return

	# Parse rows
	while not file.eof_reached():
		var row := file.get_csv_line()
		if row.size() < 3 or row[0].strip_edges().is_empty():
			continue

		var key := row[0].strip_edges()
		_translations[key] = {
			LOCALE_TH: row[th_col].strip_edges() if th_col < row.size() else key,
			LOCALE_EN: row[en_col].strip_edges() if en_col < row.size() else key,
		}

	# Register translations with Godot's TranslationServer
	_register_godot_translations()


func _register_godot_translations() -> void:
	for locale in [LOCALE_TH, LOCALE_EN]:
		var translation := Translation.new()
		translation.locale = locale
		for key in _translations:
			translation.add_message(key, _translations[key].get(locale, key))
		TranslationServer.add_translation(translation)


func _apply_locale(locale: String) -> void:
	TranslationServer.set_locale(locale)


## Set the active language.
func set_locale(locale: String) -> void:
	if locale != LOCALE_TH and locale != LOCALE_EN:
		push_warning("LocalisationManager: Unsupported locale '%s'" % locale)
		return

	current_locale = locale
	_apply_locale(locale)
	locale_changed.emit(locale)


## Toggle between Thai and English.
func toggle_locale() -> void:
	if current_locale == LOCALE_TH:
		set_locale(LOCALE_EN)
	else:
		set_locale(LOCALE_TH)


## Get translated string for a key.
func get_text(key: String) -> String:
	if key in _translations:
		return _translations[key].get(current_locale, key)
	return key


## Get translated string with format arguments.
func get_text_fmt(key: String, args: Array = []) -> String:
	var text := get_text(key)
	if not args.is_empty():
		text = text % args
	return text
