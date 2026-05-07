# DOR-142 — Ingest Validation: Executive Summary

## Problem

When a depositor submits a package to DOR Depot, the intake pipeline validates each
content file against a SHA-512 digest recorded in a `.dor/` sidecar header file. The
OCFL repository then independently computes and records its own digests in its
`inventory.json` manifest when the object is committed.

These are two separate acts of measurement on the same bits, but nothing previously
connected them. A bug or silent data corruption occurring **between** validation and
commit could go undetected indefinitely. DOR-142 closes that gap.

## What the Feature Does

`POST /admin/ingest-validation?objectId=<binId>&agentName=<name>&agentAddress=<address>`

This endpoint triggers a cross-check that answers: **"Did OCFL record the same digest
the depositor gave us?"**

For each sidecar header file (`.dor/<name>.json`) found in the committed OCFL object,
the check compares two independently-recorded digest values:

| Record                   | Source                                                     | When recorded                                         |
|--------------------------|------------------------------------------------------------|-------------------------------------------------------|
| **Inbox digest**         | `.dor/<name>.json` sidecar, `digest` or `digests[0]` field | During intake, validated against the depositor's file |
| **OCFL manifest digest** | `inventory.json` manifest, keyed by SHA-512                | At OCFL commit time, computed by the OCFL library     |

If both records agree for every file, the object passes. Any disagreement means
the bits that entered the intake pipeline are not what OCFL committed — a gap in
the chain of custody.

The result is recorded as a PREMIS `validation` event in both the OCFL log files
and the PostgreSQL catalog database, and an outcome event (`IngestValidationPassed`,
`IngestValidationDiscrepancyDetected`, or `IngestValidationTargetMissing`) is published
for downstream handling.

## Why This Matters

The standard OCFL fixity check (`PerformFixityCheck`) guarantees **internal
consistency**: the file on disk matches the digest the repository recorded for it.
DOR-142 provides **external consistency**: the digest the repository recorded matches
the digest the depositor independently verified before submission.

This is the difference between:
- "Our repository hasn't lost or corrupted the file since it was stored." *(fixity check)*
- "The file we stored is exactly what the depositor sent us." *(ingest validation)*

The second guarantee is the one stakeholders, auditors, and long-term preservation
programmes care about most. Running both back-to-back gives the complete chain of
custody: depositor → intake pipeline → OCFL storage.

## Design Decisions

### Metadata cross-check (the "Roger Algorithm")

The implementation performs a **pure metadata cross-check**: compare the sidecar's
inbox digest against the OCFL manifest digest. These are two independently-recorded
values that must agree if the ingest pipeline handled the file correctly. No physical
file is re-read; no hash is recomputed at validation time.

This is intentionally distinct from the OCFL fixity check (`PerformFixityCheck`),
which reads the physical bits and compares them against OCFL's own recorded digest.
The two checks are complementary and address different failure modes:

| Check                           | Question answered                             | Failure means                                              |
|---------------------------------|-----------------------------------------------|------------------------------------------------------------|
| **Ingest validation** (DOR-142) | Sidecar digest == OCFL manifest digest?       | Ingest pipeline introduced an error during handoff         |
| **OCFL fixity check**           | Physical file digest == OCFL manifest digest? | Storage corruption occurred after the object was committed |


### Accessing the OCFL manifest digest

The OCFL Java library exposes manifest digests through `ObjectDetails`, obtained
via `repo.describeObject(id)`. Each `FileDetails` in the head version's file list
carries a `getFixity()` map keyed by `DigestAlgorithm`. The SHA-512 manifest digest
is accessed as `fileDetails.getFixity().get(DigestAlgorithmRegistry.sha512)`.

This is exposed through the `PreservationGateway` abstraction as
`getContentFileDigests(String objectId)`, which returns a `Map<String, String>`
of logical path → SHA-512 hex.

### Sidecar format handling

Two sidecar formats exist in the repository:

| Resource type | Sidecar format  | Digest field                        |
|---------------|-----------------|-------------------------------------|
| Curio         | `MinimalHeader` | `"digest": "hex..."`                |
| Glam          | `Header`        | `"digests": ["urn:sha-512:hex..."]` |

The implementation accepts both: it first looks for a top-level `digest` key (Curio),
then falls back to a `digests` array with optional `urn:sha-512:` prefix (Glam). This
means the same validation logic works for all current resource types without branching
on type.

### PREMIS event

The result is recorded as a `PreservationEventType.VALIDATION` event — a PREMIS
event type dedicated to this kind of cross-system checking. The event carries:
- The outcome (`SUCCESS` or `FAILURE`)
- A human-readable `outcomeDetail` listing any per-file digest mismatches
- The executing agent (`system`) and requesting agent (the caller's address)

This gives preservation managers a queryable audit trail of every ingest validation
run, which is particularly important when failures indicate a systemic intake problem.


## Implementation

| Component                                       | Change                                                                                        |
|-------------------------------------------------|-----------------------------------------------------------------------------------------------|
| `PreservationGateway` (interface)               | Added `getContentFileDigests(String objectId): Map<String, String>`                           |
| `OcflPreservationGateway`                       | Implemented via `FileDetails.getFixity(DigestAlgorithmRegistry.sha512)`                       |
| `IntegrityService.performIngestValidation()`    | Metadata cross-check: sidecar inbox digest vs. OCFL manifest digest                           |
| `IntegrityService.extractDigest()`              | Helper; handles both Curio (`"digest"`) and Glam (`"digests"`) formats                        |
| `IngestValidationResultOnObjectTest`            | Asserts `IngestValidationPassed` + PREMIS `SUCCESS` on a clean ingest                         |
| `IngestValidationResultOnCorruptedObjectTest`   | Corrupts the sidecar digest; asserts `IngestValidationDiscrepancyDetected` + PREMIS `FAILURE` |
| `IngestValidationResultOnNonExistentObjectTest` | Asserts `IngestValidationTargetMissing` for unknown object ID                                 |

All tests pass: `./gradlew test` → BUILD SUCCESSFUL.

## Testing

Three test scenarios cover the feature:

| Test class                                      | Scenario                                      | Expected outcome                                         |
|-------------------------------------------------|-----------------------------------------------|----------------------------------------------------------|
| `IngestValidationResultOnObjectTest`            | Clean ingest — sidecar and manifest agree     | `IngestValidationPassed` + PREMIS `SUCCESS`              |
| `IngestValidationResultOnCorruptedObjectTest`   | Sidecar tampered — digest replaced with zeros | `IngestValidationDiscrepancyDetected` + PREMIS `FAILURE` |
| `IngestValidationResultOnNonExistentObjectTest` | Object ID does not exist in OCFL              | `IngestValidationTargetMissing`                          |

The tampering test physically overwrites the sidecar JSON file on disk (bypassing the
OCFL API) to replace its recorded digest with an all-zeros value. This simulates an
ingest handoff error — the sidecar and the OCFL manifest no longer agree — without
touching the content file itself. Post-commit physical corruption is left to the
OCFL fixity check (`PerformFixityCheck`) to detect.
