# Content Coverage — Base Game vs DLC

Generated 2026-10-17 from `repak list` across all 19 paks.
Heuristic mapping by localization target naming (`_dlc1`..`_dlc4`) and folder paths.

## LocRes targets by content group

### Base game (no _dlc suffix)

```
Academy_Dialogues, Chelomey_Dialogues, ChelomeyFinal_Dialogues, CUTSCENES,
DIALOGUES FOR LQA, Misc, NewP5, NTD, OpenWorldVDNKh_Dialogues, Pavlov_Dialogues,
PearTerminals, Polygon_Dialogues, Schebetar_Subs, SettingAppliers, Theatre_Dialogues,
VDNKh_Dialogues, Vavilov_Dialogues
```

These are the campaign locations/academy/theatre/VDNKh/Pavlov/Vavilov/Chelomey
dialogue sets, cutscenes, notes (NTD), Pear terminals, mails (Mails_01), and misc UI.

### DLC 1 (Marshes / Mendeleev)

```
Cutscenes_dlc1, Marshes_dlc1, Mendeleev_dlc1, Schebetars_dlc1
```

### DLC 2 (Locations / Tech / Shebetars mail)

```
Locations_dlc2, Mails_Shebetars_dlc2, Tech_dlc2
```

### DLC 3 (Sakhalin / Triton / Chelomey / Tech)

```
Chelomey_dlc3, Mails_Shebetars_Tech_dlc3, Sakhalin_dlc3, Tech_dlc3, Triton_dlc3
```

### DLC 4 (CrystalComplex / LebedevLab / Phasatron / WavePlatform)

```
CrystalComplex_dlc4, LebedevLab_dlc4, Mails_Shebetars_dlc4, Phasatron_dlc4,
Tech_dlc4, WavePlatform_dlc4
```

### Engine / shared (not game-content, lower priority)

```
Engine, OnlineSubsystem, OnlineSubsystemSteam, OnlineSubsystemUtils
```

## Confidence

- **LIKELY:** the `_dlc1`..`_dlc4` suffixes map 1:1 to DLC 1..4. This is inferred from
  naming, not from Steam depot metadata (Atomic Heart ships one depot 668581; all DLC
  content is inside the same paks).
- **UNKNOWN:** whether every DLC is actually installed/enabled. Steam ACF lists a single
  depot (668581) with no separate DLC appmanifests, so all DLC data appears to be present
  in the shared paks. In-game verification needed to confirm which DLC are owned.

## Note on DLC text storage

DLC narrative text is split between LocRes (above) and cooked assets, e.g.:
```
AtomicHeart/Content/DLC/NTD/DataTables/DLC1/NTD_StringTable_DLC1.uasset
AtomicHeart/Content/DLC/DLC01_Narrative/DLC01_Goose/ST_DLC01_Goose_Sentences.uasset
AtomicHeart/Content/DLC2/Narrative/GooseRunner/ST_DLC02_Gooserunner_Tutorial.uasset
AtomicHeart/Content/DLC3/Narrative/Sakhalin/ST_NTD_DLC3.uasset
AtomicHeart/Content/DLC4/Narrative/NarrSubs/ST_NTD_DLC4.uasset
```
So DLC coverage will also require non-locres extraction (see LOCALIZATION_FORMAT.md §2).
