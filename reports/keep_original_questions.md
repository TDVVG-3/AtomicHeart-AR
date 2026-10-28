# Keep-original item-name questions

Generated: 2026-10-27 22:57:07 +03:00

These rows were found in item-definition assets but are **not** changed to English by default.
They are excluded from `localization/working/keep_original.tsv` and left exactly as they are in the master.

## Excluded rows

| master line | scope | key | source English | current Arabic | asset | why excluded |
|---:|---|---|---|---|---|---|
| 13194 | NewP5 | `/E9269E5C43C7E0547510C2AF219A75B2` | Extra Capacity Cartridges | خراطيش بسعة إضافية | `Core/Data/Skills/Character/SkillsSqueezedInCharacter/DA_CassetteCapacity.uasset` | not an inventory/weapon item NAME row, or source is not an English item name |
| 12284 | NewP5 | `/E6ECF9EC46E601E855388C9748089247` | Cell Division | انقسام الخلايا | `Core/Data/Skills/Character/SkillsSqueezedInCharacter/DA_ConsumableAfterHealRegen.uasset` | not an inventory/weapon item NAME row, or source is not an English item name |
| 12182 | NewP5 | `/BAEB863F47A0F3CC4AD19488FB83C33C` | КS-23—COLLIMATOR | КS-23—كوليماتور | `Core/Objects/Items/Weapons/Upgrades/KS23/DA_Item_KS23_Scope_RedDot_Recipe.uasset` | not an inventory/weapon item NAME row, or source is not an English item name |
| 12185 | NewP5 | `/26AD73004FF45B5AFD4D8A9B8002F8FB` | КS-23—THERMAL SCOPE | КS-23—منظار حراري | `Core/Objects/Items/Weapons/Upgrades/KS23/DA_Item_KS23_Scope_ThermalScope_Recipe.uasset` | not an inventory/weapon item NAME row, or source is not an English item name |
| 20298 | Tech_dlc2 | `/9541C5DD48051484015ECDA23731F438` | КОММУНИКАТОР | جهاز الاتصال | `DLC2/Development/BP_Objects/Intaractive/Pickupable/DA_Item_AudioDiary_DLC2.uasset` | not an inventory/weapon item NAME row, or source is not an English item name |

## Reviewed and resolved as items/weapons

The following short terms could look like abilities or locations. They were checked against the item asset path and are kept in English:

- `JAB` - `DA_Item_Shprits` (syringe weapon)
- `BINGUN` - `DA_Item_Bidonist` (weapon)
- `CAROUSEL` - `DA_Item_Karusel` (weapon)
- `ECHIDNA` - `DA_Item_Dikobraz` (weapon)
- `PARAGRAPH` - `DA_Item_Abzac` (weapon)
- `SINGER` - `DA_Item_Zinger` (weapon)
- `ROOSTER` - `DA_Item_Petuh` (weapon)
- `DYNAMO` - `DA_Consumable_energetic` (consumable)
- `SPIRAL` - `DA_Item_Metal_Spiral` (metal resource)
- `CHEMISTRY` - `DA_Item_Resources_Chemicals` (resource)
- `VALVE` - `DA_item_Ventel` (quest item)
- `ORB` - `DA_Item_PuzzleBall` (puzzle item)
- `Launch module` - `DA_Consumable_Alenka` (quest consumable)
- `Candle` - `DA_Item_PickupableBall` (DLC3 quest item)
- `Keycard` - `DA_Item_UnderwaterBallon` (DLC3 quest item)
- `Scuba gear` - `DA_Item_Scuba` (DLC3 equipment)
- `Repair Module` - `DA_Item_ModuleForRepair` (DLC3 item)
- `Thunderclap` - `DA_Item_Gromoverzhec` (DLC3 melee weapon)
- `KM-4 Kuzmich` - `DA_Item_Kuzmich` (DLC3 ranged weapon)
- `NECHAEV'S FAVORITE CANISTER` - `DA_Item_LimboPuzzle` (DLC2 quest item; the character name is part of the item name)
- `DebugGun` / `DebugMelee` - `DA_Item_DebugGun` / `DA_Item_DebugMelee` (debug weapons; kept for completeness, not expected in normal play)

## Open question

`ÐšÐžÐœÐœÐ£ÐÐ˜ÐšÐÐ¢ÐžÐ ` (Tech_dlc2) is the DLC2 audio-diary item. Its source cell is Russian, not English, so copying it would put Russian in the Arabic UI, and translating it would break the keep-original rule. It is left as the current Arabic `Ø¬Ù‡Ø§Ø² Ø§Ù„Ø§ØªØµØ§Ù„`. If a reviewer wants this one unified with the base item `COMMUNICATOR`, add a copy-class row for it explicitly.

`ÐšS-23â€”COLLIMATOR` and `ÐšS-23â€”THERMAL SCOPE` use a Cyrillic `Ðš` in the source. They are weapon upgrades, but copying the mixed-script source would inject Cyrillic into the Arabic cell. They are left translated. If the Cyrillic is a source typo, the correct English form should be `KS-23â€”COLLIMATOR` / `KS-23â€”THERMAL SCOPE`; add them explicitly after review.
