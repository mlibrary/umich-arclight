# ARC-124 Status

## Last Updated
2026-05-20 - Developer verified no additional subtasks; ARC-124 implementation task is complete.

## Current Branch
`ARC-124-Page-with-empty-link`

## Open Tasks
### Remove Empty Processing Information Link on `umich-bhl-2011097`
- [x] Reproduce the empty-link rendering on `catalog/umich-bhl-2011097` and identify the view/presenter code path that emits the link
- [x] Inspect the source EAD data for `umich-bhl-2011097` to confirm which Processing Information field is blank or malformed
- [x] Implement a targeted fix so no anchor renders when link text or href is effectively empty, while preserving valid links on other records
- [x] Add or update a test that would fail before the fix and pass after the fix
- [x] Verify the current state of the project achieves the task goal
- [x] Verify with the developer that the task is complete

Key files (expected):
- `app/presenters/` (Arclight metadata/link rendering path)
- `app/views/` (component/field templates for Processing Information)
- `spec/` or `test/` coverage for rendering behavior
- sample or fixture data for `umich-bhl-2011097` if available

## Open Plans
| Plan File | Purpose | Status |
|-----------|---------|--------|
| *(none)*  |         |        |

## Recent Activity
- Updated `app/controllers/concerns/arclight/ead_format_helpers.rb` to skip rendering links when `href` exists but visible link text is blank.
- Added regression tests in `spec/controllers/catalog_controller_spec.rb` covering empty and non-empty `extref` rendering.
- Brought up Docker services and initialized local test prerequisites (`bundle install`, `rails db:setup`, Solr test core creation).
- Verified changes with `docker-compose exec -- app bundle exec rspec spec/controllers/catalog_controller_spec.rb | cat` and targeted RuboCop.
- Confirmed with developer that no additional subtasks are needed for ARC-124.

## Key Context
- Reported issue is a single Siteimprove finding on `https://findingaids.lib.umich.edu/catalog/umich-bhl-2011097`.
- The issue is described as an empty link rendered under "Processing information." 
- Goal is to remove the empty/invalid link without regressing valid link rendering on other records.
- The rendering path for this issue is `render_html_tags` -> `transform_ead_to_html` -> `format_links` in `Arclight::EadFormatHelpers`.
- The specific `umich-bhl-2011097` EAD file is not present in local `data/` or `sample-ead/`; regression coverage uses focused `extref` rendering examples to validate the behavior change.

## Next Steps
1. Commit ARC-124 changes, including `tasks/ARC-124/TODO.md`, `tasks/ARC-124/DONE.md`, and `tasks/ARC-124/STATUS.md`.
2. Open/update PR for reviewer confirmation against Siteimprove scan results.

