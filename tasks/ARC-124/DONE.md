# ARC-124 Done

## Completed
2026-05-20 - Removed empty Processing Information link rendering for `catalog/umich-bhl-2011097` and added regression coverage for empty/non-empty EAD links.

## Completed Checklist

### Remove Empty Processing Information Link on `umich-bhl-2011097`
- [x] Reproduce the empty-link rendering on `catalog/umich-bhl-2011097` and identify the view/presenter code path that emits the link
- [x] Inspect the source EAD data for `umich-bhl-2011097` to confirm which Processing Information field is blank or malformed
- [x] Implement a targeted fix so no anchor renders when link text or href is effectively empty, while preserving valid links on other records
- [x] Add or update a test that would fail before the fix and pass after the fix
- [x] Verify the current state of the project achieves the task goal
- [x] Verify with the developer that the task is complete

## Verification Notes
- `docker-compose exec -- app bundle exec rspec spec/controllers/catalog_controller_spec.rb | cat`
- `docker-compose exec -- app bundle exec rubocop app/controllers/concerns/arclight/ead_format_helpers.rb spec/controllers/catalog_controller_spec.rb | cat`

