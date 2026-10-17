# Spec Integrity Guard

Authoritative file: `C:\AtomicHeart-AR\MASTER_PROMPT.md`
Backup copy: `C:\AtomicHeart-AR\docs\spec\MASTER_PROMPT.backup.md`
Hash record: `docs/spec/MASTER_PROMPT.sha256` (this file)

## Reference hash (recorded 2026-10-17)

```
SHA256(MASTER_PROMPT.md)        = 579f581e5bb8caae2aff6ef60326f1f461688f1b1392391a56a97a6148a61c35
SHA256(MASTER_PROMPT.backup.md) = 579f581e5bb8caae2aff6ef60326f1f461688f1b1392391a56a97a6148a61c35
size = 34293 bytes
```

## Standing procedure (permanent, per user decision of 2026-10-17)

1. At the start of EVERY work cycle: compute SHA256 of MASTER_PROMPT.md.
2. If the hash matches the reference: proceed.
3. If the hash MISMATCHES:
   - Restore MASTER_PROMPT.md automatically from the backup copy.
   - Re-verify the hash after restore.
   - Note the incident in the cycle's `lastreport.md` (Problems section).
   - Do NOT stop the cycle for this; log and continue.
4. Both spec files are set read-only (attrib +R). They are never edited by agents.
5. If the reference text itself is ever legitimately updated, the user must say so,
   and the backup + hashes must be regenerated at that time.
