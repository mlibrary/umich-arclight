# STATUS — DOR-142

**Last Updated:** 2026-05-01 — Branch re-rooted on main; quiz updated for DOR-142 changes

## Current Branch

`DOR-142/ingest-validation`

Branch was reset to `main` and the DOR-142 content migrated from the old flat layout
(root-level `AGENT_TODO.md`, `AGENT_DONE.md`, `AGENT_STATUS.md`, `plans/`) to the
current `tasks/DOR-142/` framework. All Java code changes preserved intact.

## Open Tasks

No open tasks. All DOR-142 subtasks are complete. See `DONE.md`.
Next step: address PR review feedback if any.

## Open Plans

| File                                        | Purpose                                              | Status |
|---------------------------------------------|------------------------------------------------------|--------|
| `tasks/DOR-142/plans/DOR-142-summary.md`    | Executive summary — problem, design, implementation  | Done   |
| `tasks/DOR-142/plans/DOR-142.md`            | Ingest validation — design, algorithm, current state | Done   |

## Recent Activity

- Branch reset to `main` and re-rooted; all agent framework files now current versions
- `plans/DOR-142.md` and `plans/DOR-142-summary.md` migrated → `tasks/DOR-142/plans/`
- `AGENT_TODO.md`, `AGENT_DONE.md`, `AGENT_STATUS.md` migrated → `tasks/DOR-142/`
- Old `IntegrityCheck*`/`PerformIntegrityCheck` classes and tests removed (superseded by `FixityCheck*`)
- `tasks/README.md` updated to list DOR-142 as active
- `AGENT_QUIZ.md` Q14 updated: four endpoints (not three); Q27 updated: two command handlers
- `AGENT_QUIZ_ANSWERS.md` A14/A27 updated to match current `IntegrityService` and `AdminController`

## Key Context

### Implementation Summary
This branch refactors the existing integrity-check feature and adds a new ingest validation
endpoint, all under `IntegrityService`:

- **Rename**: `IntegrityCheck*` → `FixityCheck*` (events, commands, result); `checkIntegrity` → `checkFixity`
- **New**: `PerformIngestValidation` command → `IntegrityService.performIngestValidation()`
  - Iterates all `.dor/` sidecar files in the OCFL object
  - Reads each sidecar's recorded inbox digest
  - Compares against the OCFL manifest digest (`getContentFileDigests()`)
  - Writes a PREMIS `VALIDATION` event; publishes `IngestValidationPassed` or `IngestValidationDiscrepancyDetected`
- **New endpoint**: `POST /admin/ingest-validation` in `AdminController`
- **New gateway method**: `getContentFileDigests(String objectId)` in `PreservationGateway` / `OcflPreservationGateway`

### Key Files
- `src/main/java/edu/umich/lib/dor/depot/preservation/IntegrityService.java`
- `src/main/java/edu/umich/lib/dor/depot/preservation/OcflPreservationGateway.java`
- `src/main/java/edu/umich/lib/dor/depot/preservation/PreservationGateway.java`
- `src/main/java/edu/umich/lib/dor/depot/console/AdminController.java`

## Next Steps

1. Address any feedback from the DOR-142 PR review.
2. Once PR is approved and merged, archive: `git mv tasks/DOR-142 archive/DOR-142` on `agents` branch.

