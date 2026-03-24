## ReviewParser — Parses AI review response text into structured sections.
## Extracts: Overall Assessment, Strengths, Areas for Improvement, Critical Errors, Recommendations.
## Handles malformed responses with fallback to raw text.
extends Node

## Emitted when a review has been successfully parsed.
signal review_parsed(review_data: Dictionary)

## Section header markers — matches the system prompt's expected format.
const SECTION_HEADERS := {
	"overall_assessment": ["## Overall Assessment", "**Overall Assessment**", "Overall Assessment"],
	"strengths": ["## Strengths", "**Strengths**", "Strengths"],
	"improvements": ["## Areas for Improvement", "**Areas for Improvement**", "Areas for Improvement"],
	"critical_errors": ["## Critical Errors", "**Critical Errors**", "Critical Errors"],
	"recommendations": ["## Recommendations", "**Recommendations**", "Recommendations"],
}


## Parse a review response text into structured sections.
## Returns a Dictionary with extracted sections + raw_text.
func parse_review(response_text: String) -> Dictionary:
	if response_text.strip_edges() == "":
		return _fallback_result(response_text)

	var result := {
		"overall_assessment": "",
		"strengths": [] as Array[String],
		"improvements": [] as Array[String],
		"critical_errors": [] as Array[String],
		"recommendations": [] as Array[String],
		"raw_text": response_text,
		"parsed_successfully": false,
	}

	# Try to extract each section
	result["overall_assessment"] = _extract_section(response_text, "overall_assessment")
	result["strengths"] = _extract_bullet_section(response_text, "strengths")
	result["improvements"] = _extract_bullet_section(response_text, "improvements")
	result["critical_errors"] = _extract_bullet_section(response_text, "critical_errors")
	result["recommendations"] = _extract_bullet_section(response_text, "recommendations")

	# Check if parsing was successful (at least overall_assessment found)
	if result["overall_assessment"] != "" or result["strengths"].size() > 0:
		result["parsed_successfully"] = true

	review_parsed.emit(result)
	return result


## Extract a text section (paragraph content between headers).
func _extract_section(text: String, section_key: String) -> String:
	var headers: Array = SECTION_HEADERS.get(section_key, [])
	var section_start := -1
	var header_length := 0

	# Find the section header
	for header: String in headers:
		var pos := text.find(header)
		if pos >= 0:
			section_start = pos + header.length()
			header_length = header.length()
			break

	if section_start < 0:
		return ""

	# Find the next section header (any section)
	var section_end := text.length()
	for other_key: String in SECTION_HEADERS:
		if other_key == section_key:
			continue
		var other_headers: Array = SECTION_HEADERS[other_key]
		for header: String in other_headers:
			var pos := text.find(header, section_start)
			if pos >= 0 and pos < section_end:
				section_end = pos

	var content := text.substr(section_start, section_end - section_start)
	return _clean_text(content)


## Extract a bullet-point section as an array of strings.
func _extract_bullet_section(text: String, section_key: String) -> Array[String]:
	var section_text := _extract_section(text, section_key)
	if section_text == "":
		return []

	var bullets: Array[String] = []
	var lines := section_text.split("\n")

	for line: String in lines:
		var trimmed := line.strip_edges()
		if trimmed == "":
			continue

		# Remove bullet markers (-, *, •, numbered)
		if trimmed.begins_with("- "):
			trimmed = trimmed.substr(2)
		elif trimmed.begins_with("* "):
			trimmed = trimmed.substr(2)
		elif trimmed.begins_with("• "):
			trimmed = trimmed.substr(2)
		else:
			# Check for numbered bullets (1. 2. etc.)
			var dot_pos := trimmed.find(". ")
			if dot_pos >= 0 and dot_pos <= 2 and trimmed.substr(0, dot_pos).is_valid_int():
				trimmed = trimmed.substr(dot_pos + 2)

		trimmed = _strip_markdown(trimmed)
		if trimmed != "":
			bullets.append(trimmed)

	return bullets


## Clean extracted text — strip leading/trailing whitespace and empty lines.
func _clean_text(text: String) -> String:
	var lines := text.split("\n")
	var cleaned: Array[String] = []
	var found_content := false

	for line: String in lines:
		var trimmed := line.strip_edges()
		if trimmed == "" and not found_content:
			continue  # Skip leading empty lines
		found_content = true
		cleaned.append(trimmed)

	# Remove trailing empty lines
	while cleaned.size() > 0 and cleaned[-1] == "":
		cleaned.pop_back()

	return "\n".join(cleaned)


## Strip markdown formatting for clean display text.
func _strip_markdown(text: String) -> String:
	var result := text

	# Strip bold markers
	result = result.replace("**", "")
	result = result.replace("__", "")

	# Strip italic markers (single * or _)
	# Be careful not to strip multiplication or underscores in identifiers
	if result.begins_with("*") and result.ends_with("*") and result.length() > 2:
		result = result.substr(1, result.length() - 2)
	if result.begins_with("_") and result.ends_with("_") and result.length() > 2:
		result = result.substr(1, result.length() - 2)

	# Strip inline code backticks
	result = result.replace("`", "")

	return result.strip_edges()


## Fallback result when parsing fails completely.
func _fallback_result(response_text: String) -> Dictionary:
	var result := {
		"overall_assessment": "",
		"strengths": [] as Array[String],
		"improvements": [] as Array[String],
		"critical_errors": [] as Array[String],
		"recommendations": [] as Array[String],
		"raw_text": response_text,
		"parsed_successfully": false,
	}
	review_parsed.emit(result)
	return result


## Validate that a parsed review has sufficient content for display.
func is_review_complete(review_data: Dictionary) -> bool:
	if not review_data.get("parsed_successfully", false):
		return false
	if review_data.get("overall_assessment", "") == "":
		return false
	return true
