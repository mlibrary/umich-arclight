## Remove Empty Processing Information Link on `umich-bhl-2011097`
Investigate and fix the one-page accessibility issue where an empty link appears under Processing Information on `catalog/umich-bhl-2011097`.

- [x] Reproduce the empty-link rendering on `catalog/umich-bhl-2011097` and identify the view/presenter code path that emits the link
- [x] Inspect the source EAD data for `umich-bhl-2011097` to confirm which Processing Information field is blank or malformed
- [x] Implement a targeted fix so no anchor renders when link text or href is effectively empty, while preserving valid links on other records
- [x] Add or update a test that would fail before the fix and pass after the fix
- [x] Verify the current state of the project achieves the task goal
- [x] Verify with the developer that the task is complete

