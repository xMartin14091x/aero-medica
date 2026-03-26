## SecondarySurveyManager — Body-region secondary survey system.
## Phase 5 (MON-15): Head-to-toe examination with findings from scenario JSON.
## Gated behind primary survey completion (DRSABCDE must be done first).
extends Node

## Body regions in examination order.
const BODY_REGIONS: Array[String] = [
	"head", "neck", "chest", "abdomen", "pelvis", "back", "extremities"
]

const REGION_LABELS: Dictionary = {
	"head": "Head & Face",
	"neck": "Neck & Cervical Spine",
	"chest": "Chest & Thorax",
	"abdomen": "Abdomen",
	"pelvis": "Pelvis",
	"back": "Back & Spine",
	"extremities": "Extremities",
}

## Keywords that mark a finding as critical (triggers alert).
const CRITICAL_KEYWORDS: Array[String] = [
	"fracture", "bleeding", "laceration", "unstable", "tension",
	"pneumothorax", "fixed", "dilated", "ICP", "absent pulse",
	"rigid", "distended", "displaced",
]

## Emitted when a body region is examined.
signal region_examined(region: String, findings: String, is_critical: bool)

## Emitted when all 7 regions are examined.
signal survey_complete(patient: Node)


## Get findings for a specific region from a patient's MedicalStateComponent.
## Uses Thai findings if locale is "th" and Thai data exists.
func get_region_findings(patient: Node, region: String) -> String:
	var medical: Node = patient.get_node_or_null("MedicalStateComponent")
	if not medical:
		return "Unable to assess."
	# Check if Thai findings are available and locale is Thai
	var locale := TranslationServer.get_locale()
	if locale.begins_with("th"):
		var findings_th: Dictionary = medical.get("examination_findings_th") if medical.get("examination_findings_th") != null else {}
		if not findings_th.is_empty() and findings_th.has(region) and str(findings_th[region]) != "":
			return str(findings_th[region])
	var findings: Dictionary = medical.examination_findings
	return findings.get(region, "No significant findings.")


## Check if findings text contains critical keywords.
func is_critical_finding(findings: String) -> bool:
	var lower := findings.to_lower()
	for keyword in CRITICAL_KEYWORDS:
		if keyword in lower:
			return true
	return false


## Get all regions with their labels.
func get_all_regions() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for region in BODY_REGIONS:
		result.append({
			"key": region,
			"label": REGION_LABELS.get(region, region),
		})
	return result


## Check if primary survey is complete on a patient (required before secondary).
func is_primary_survey_complete(patient: Node) -> bool:
	if not patient.has_meta("assessed_conditions"):
		return false
	var assessed: Dictionary = patient.get_meta("assessed_conditions")
	# Primary survey requires at minimum: airway, breathing, pulse assessed
	return (assessed.has("assess_airway") and
			assessed.has("assess_breathing") and
			assessed.has("assess_pulse"))


## Perform examination of a body region. Emits signal with findings.
func examine_region(patient: Node, region: String) -> Dictionary:
	if not is_primary_survey_complete(patient):
		return {"error": "Complete primary survey (DRSABCDE) before secondary survey."}
	var findings := get_region_findings(patient, region)
	var critical := is_critical_finding(findings)
	region_examined.emit(region, findings, critical)
	# Track examined regions on patient
	if not patient.has_meta("secondary_survey_regions"):
		patient.set_meta("secondary_survey_regions", [])
	var examined: Array = patient.get_meta("secondary_survey_regions")
	if region not in examined:
		examined.append(region)
		patient.set_meta("secondary_survey_regions", examined)
	# Check if all regions done
	if examined.size() >= BODY_REGIONS.size():
		survey_complete.emit(patient)
	return {
		"region": region,
		"label": REGION_LABELS.get(region, region),
		"findings": findings,
		"is_critical": critical,
		"regions_done": examined.size(),
		"regions_total": BODY_REGIONS.size(),
	}


## Get count of examined regions for a patient.
func get_examined_count(patient: Node) -> int:
	if not patient.has_meta("secondary_survey_regions"):
		return 0
	return patient.get_meta("secondary_survey_regions").size()
