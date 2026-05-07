# DONE

## 2026-04-30 — DOR-142: Ingest Validation

Implemented the ingest validation cross-check (the "Roger Algorithm"): a pure metadata
comparison of the sidecar inbox digest against the OCFL manifest digest, proving the
ingest pipeline handed off the correct bits from depositor to repository. Includes PREMIS
`VALIDATION` event writing, three test scenarios, an executive summary, and a comprehensive
rename of fixity-check events/commands to use precise OCFL/PREMIS terminology.
PR open and awaiting review on `DOR-142/ingest-validation`.

- [x] Run existing ingest validation tests to confirm which pass and which fail
- [x] Add PREMIS `VALIDATION` event writing to `IntegrityService.performIngestValidation()`
- [x] Generalise the header-file scan: iterate over all `.dor/` sidecar files
- [x] Remove vestigial `checkIngestValidation()` from `PreservationGateway`
- [x] Run the full test suite with Docker running: `./gradlew test | cat`
- [x] Write executive summary in `tasks/DOR-142/plans/DOR-142-summary.md`
- [x] Implement proper metadata cross-check via `getContentFileDigests()` on gateway
- [x] Verify with the developer that the task is complete

