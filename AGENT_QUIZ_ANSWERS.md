# Agent Onboarding Quiz — Answer Key

> ⚠️ **DO NOT READ THIS FILE** until you have answered all 20 questions in
> `AGENT_QUIZ.md` and the developer has told you to compare your answers.
> Reading this file before completing the quiz defeats its purpose.

---

> Every answer below can be verified by reading the cited source file.
> If an answer here contradicts what you find in the source, **the source file wins**.

---

**A1.** Add the plan to `tasks/ARC-nnn/TODO.md` as a new task with subtasks before taking any action.
Do not begin execution until the plan is recorded.
*(Source: `AGENTS.md` § Task Tracking — "Before executing any multi-step plan, record it in `TODO.md` first")*

---

**A2.** Always use **Python** (`re.split` on `## ` headings, reorder list, rewrite file).
Never use **string-search-and-replace** — task bodies contain long text that makes
patterns brittle and prone to corrupting the file.
*(Source: `AGENTS.md` § Reordering Subtasks in `tasks/ARC-nnn/TODO.md`)*

---

**A3.** Create a **new commit** on top of HEAD with `git commit`. Never use `git commit --amend`.
The developer will squash commits manually as needed.
*(Source: `AGENTS.md` § Git Commits)*

---

**A4.** `python3 -c "..."` fails in zsh whenever the code spans multiple lines or contains
inner quotes. zsh treats the unclosed double-quote as the start of a heredoc (`dquote>`
prompt), corrupts the command, and can hang the terminal session.

**The universal fix — write to a file, run the file:**
1. Use `insert_edit_into_file` or `create_file` to write the code to a file:
   - Reusable script → `dotpy/myscript.py`
   - Truly one-off → `/tmp/run.py`
2. Run it: `python3 dotpy/myscript.py | cat`

The single-line `-c` form is safe only when the command fits on one line, contains no
inner quotes, and has no `$` expansions.
*(Source: `AGENTS.md` § Command-Line Tool Usage)*

---

**A5.**
1. `python3 dotpy/format_table.py <file.md>` — rewrites the file with all tables correctly padded
2. `python3 dotpy/check_tables.py <file.md>` — exits 0 if all tables are consistent, 1 with errors

*(Source: `AGENTS.md` § Markdown Formatting)*

---

**A6.** Ruby **2.7** — the base Docker image is `ruby:2.7`.
*(Source: `Dockerfile` — `FROM ruby:2.7`)*

---

**A7.** Rails **~> 5.2.3** (i.e., 5.2.x).
*(Source: `Gemfile` — `gem 'rails', '~> 5.2.3'`)*

---

**A8.** Core local-development services and their localhost ports:

| Service | Image              | Localhost port |
|---------|--------------------|----------------|
| `db`    | postgres:12-alpine | 5432           |
| `solr`  | solr:8-slim        | 8983           |
| `redis` | redis:8-bookworm   | 6379           |
| `app`   | umich-arclight     | 3000           |

(`resque` and `resque-web` are also defined in `docker-compose.yml`, but they are
not part of the four core services asked in Q8.)

*(Source: `docker-compose.yml`)*

---

**A9.**
```shell
docker-compose exec -- app bundle exec rails s -b 0.0.0.0
```
The application is available at **http://localhost:3000/**
*(Source: `README.md` § Start development rails server)*

---

**A10.** Two test suites:
- **MiniTest**: `docker-compose exec -- app bundle exec rake test`
- **RSpec**: `docker-compose exec -- app bundle exec rake spec`

The single rake command that runs rubocop + both test suites:
```shell
docker-compose exec -- app bundle exec rake
```
This is defined in `lib/tasks/default.rake` as:
`task(:default).clear.enhance %i[environment rubocop test spec]`

Note: JavaScript linting (`rake lint`) is **not** included in the default task and must be run separately.

*(Source: `README.md` § Continuous Integration; `lib/tasks/default.rake`)*

---

**A11.**
Auto-fix safe offences:
```shell
docker-compose exec -- app bundle exec rubocop -a | cat
```
Report remaining violations:
```shell
docker-compose exec -- app bundle exec rubocop | cat
```
*(Source: `AGENTS.md` § Ruby on Rails Conventions)*

---

**A12.** This application is **UMich ArcLight (Finding Aids)** — a discovery and access
application for archival material at University of Michigan Libraries, built on the
ArcLight and Blacklight Rails engines.

It uses **EAD (Encoded Archival Description) XML** files as the finding aid format.

EAD files are stored under `<FINDING_AID_DATA>/ead/<repository-slug>/`.
The default value of `FINDING_AID_DATA` is `/data` (from `lib/dul_arclight.rb`).
In the Docker container it is overridden to `/var/opt/app/data` (from `Dockerfile`).

*(Source: `README.md`; `lib/dul_arclight.rb` — `ENV.fetch('FINDING_AID_DATA', '/data')`; `Dockerfile`)*

---

**A13.** Eight repository slugs:

| Slug          | Institution name                                                  |
|---------------|-------------------------------------------------------------------|
| `bhl`         | University of Michigan Bentley Historical Library                 |
| `scrc`        | University of Michigan Special Collections Research Center        |
| `clements`    | University of Michigan William L. Clements Library                |
| `clarke`      | Central Michigan University Clarke Historical Library             |
| `vrc`         | University of Michigan History of Art Visual Resources Collection |
| `archivemi`   | Archives of Michigan                                              |
| `mlibraryead` | MLibrary Finding Aids                                             |
| `ghcc`        | University of Michigan Genesee Historical Collections Center      |

*(Source: `config/repositories.yml` — top-level keys)*

---

**A14.**
Index all repositories:
```shell
docker-compose exec -- app bundle exec rake dul_arclight:reindex_everything
```
(No environment variables required; reads all repository slugs from `config/repositories.yml`.)

Index one repository:
```shell
docker-compose exec -- app bundle exec rake dul_arclight:reindex_repository REPOSITORY_ID=bhl
```
Required environment variable: `REPOSITORY_ID`.

*(Source: `README.md` § Indexing EAD Files; `lib/tasks/reindex.rake`)*

---

**A15.**
```shell
docker-compose exec -- app bundle exec rake arclight:index REPOSITORY_ID=bhl FILE=/var/opt/app/data/ead/bhl/umich-bhl-032.xml
```
Required environment variables: `REPOSITORY_ID` and `FILE` (path to the EAD XML file).
*(Source: `README.md` § Index a single EAD file)*

---

**A16.** The environment variable is **`FINDING_AID_INGEST`**. In the development
environment it is set to `true` in `docker-compose.yml` under the `app` service's
`environment` block. When it equals `'true'`, the routes for `findingaids` and
`slugmaps` are added.
*(Source: `config/routes.rb` — `if ENV['FINDING_AID_INGEST'] == 'true'`; `docker-compose.yml`)*

---

**A17.** *(Answer by reading `tasks/README.md` and the relevant `tasks/ARC-nnn/STATUS.md` at the
time the quiz is taken — the active task list changes over time. The agent must look up the
current state, not rely on memory.)*

*(Source: `tasks/README.md`, `tasks/ARC-nnn/STATUS.md`)*

---

**A18.**
1. Create `tasks/ARC-nnn/DONE.md` with a timestamp, summary, and the completed checklist.
2. Run `git mv tasks/ARC-nnn archive/ARC-nnn` on the `agents` branch.
3. Update `tasks/README.md` to mark the ticket archived.
4. Commit on `agents`.

The completed ticket directory moves to **`archive/ARC-nnn/`**.
*(Source: `AGENTS.md` § Task Tracking — "Completing a ticket (after PR merges, on the `agents` branch)")*

---

**A19.** Two steps to fully recreate the database from scratch:
1. `docker-compose exec -- app bundle exec rails db:drop`
2. `docker-compose exec -- app bundle exec rails db:setup`

*(Source: `README.md` § Setup databases)*

---

**A20.** Two steps to delete and recreate a Solr core (example: `umich-arclight-test`):
1. `docker-compose exec -- solr solr delete -c umich-arclight-test`
2. `docker-compose exec -- solr solr create_core -d umich-arclight -c umich-arclight-test`

*(Source: `README.md` § Create solr cores)*
