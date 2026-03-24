# ARC-18 — Medical Bag Tier UI

**Phase:** Phase 6 — Drug Administration & Medical Bag Expansion
**Team:** Arcade — Frontend/Creative
**Status:** `[x] Complete`
**Depends on:** MON-17 (medical bag tier system)
**Blocks:** None

---

## Scope
Create the medical bag inventory interface showing tiered (BLS/ALS) equipment contents organized by category. Player browses and selects items from the bag for deployment on patients. Show quantity tracking for consumable items.

## Implementation Detail

### Bag Inventory Panel
Create a bag interaction UI — either a standalone overlay or integrated into the Stabilize tab:

```
┌──────────────────────────────────────────────┐
│  MEDICAL BAG — BLS                           │
│ ──────────────────────────────────────────── │
│                                              │
│  [PPE] [Airway] [Breathing] [Diagnostic]     │  ← Category tabs
│  [Wound Care] [Hemorrhage] [Immobilization]  │
│                                              │
│  ── Diagnostic ──────────────────────────── │
│                                              │
│  ○ Pulse Oximeter          (1)  [Deploy]     │
│  ○ BP Cuff (Manual)        (1)  [Deploy]     │
│  ○ Stethoscope             (1)  [Deploy]     │
│  ○ Penlight                (1)  [Deploy]     │
│  ○ Thermometer             (1)  [Deploy]     │
│  ○ Glucometer + Strips     (1)  [Deploy]     │
│                                              │
│  ── Deployed on Patient ────────────────── │
│  ✓ Pulse Oximeter → Somchai                  │
│  ✓ BP Cuff → Somchai                         │
│                                              │
└──────────────────────────────────────────────┘
```

### Category Tabs
Group items by category from bag tier JSON:
- **PPE:** Gloves
- **Airway:** BVM, OPA, NPA, SGA (ALS), ET tubes (ALS), laryngoscope (ALS), suction (ALS), cric kit (ALS)
- **Breathing:** O2 cylinder, NRB mask, nasal cannula
- **Diagnostic:** Pulse ox, BP cuff, stethoscope, penlight, thermometer, glucometer, cardiac monitor (ALS), ECG cables (ALS), capnography (ALS)
- **Wound Care:** Bandages, gauze, tape, triangular bandages
- **Hemorrhage:** Tourniquets, hemostatic gauze (ALS), Israeli bandage (ALS)
- **Immobilization:** SAM splint, cervical collar, pelvic binder (ALS)
- **Chest:** Needle decompression (ALS), chest seal (ALS)
- **Vascular:** IV start kit (ALS), IO drill (ALS), IV tubing (ALS)
- **Thermal:** Emergency blanket

### Quantity Display
- Show remaining quantity in parentheses
- Consumable items (bandages, gauze, etc.) decrease when used
- Non-consumable diagnostic tools show "deployed" state instead of quantity decrease
- When quantity reaches 0: item greyed out with "Depleted" label

### Deploy vs. Apply
- **Diagnostic tools** (pulse ox, BP cuff, etc.): "Deploy" button — equipment stays on patient, enables gated assessments
- **Treatment items** (bandages, tourniquets, etc.): "Apply" button — same as existing Stabilize tab behavior
- **Consumable items** decrease quantity on apply

### Bag Tier Indicator
- Show current bag tier in header: "BLS" or "ALS"
- ALS items visually distinguished (e.g., amber/gold border or "[ALS]" label)
- In BLS scenarios, ALS items are NOT shown (not greyed — absent entirely)

### Integration with Existing Systems
- Bag opens from the Stabilize tab or a dedicated bag button in HUD
- Deploying diagnostic tools immediately enables the corresponding assessment action in Exam tab
- Treatment items integrate with existing `apply_treatment()` flow

## Acceptance Criteria
- [x]Bag inventory panel shows items organized by category tabs
- [x]Items show remaining quantity with visual tracking
- [x]Consumable items decrease on use, greyed when depleted
- [x]Diagnostic tools show "deployed" state with patient assignment
- [x]Category tabs filter displayed items
- [x]Bag tier header shows BLS or ALS
- [x]ALS items only visible in ALS-tier scenarios
- [x]Deploy action enables equipment-gated assessments in Exam tab
- [x]Treatment items integrate with existing apply_treatment flow
- [x]"Deployed on Patient" section shows active diagnostic tool assignments

## Boundaries — Do NOT Touch
- Do not modify `MedicalBagTierExpansion` backend (that's MON-17)
- Do not modify drug administration section (that's ARC-17)
- Do not modify Patient/Exam/Differential tabs

## Notes
- Clinical reference: Medica Consultation Log #01, Part 3
- The tiered approach mirrors real EMS training progression
- BLS bag is the "tutorial" kit; ALS bag adds complexity for advanced players
