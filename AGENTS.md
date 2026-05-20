# Agent Rules

> **Read this file at the start of every new agent session, before taking any action.**
> These rules apply to all AI coding agents (GitHub Copilot, Claude, Cursor, etc.) working in this repository.

## File Access


- **Stay within the project directory**: Only read, write, or search files that are under the project root directory. Do not access files outside the project directory unless the developer **explicitly** requests it.
  - When a developer does request access to an outside file, read **only that specific file** — do not browse, list, or search the surrounding directory or any parent directories.
  - Never speculatively explore paths outside the project root.

- **Never read `AGENT_QUIZ_ANSWERS.md` before completing the quiz.** When taking the
  `AGENT_QUIZ.md` onboarding quiz, do not open or read `AGENT_QUIZ_ANSWERS.md` until
  you have written out answers to all 30 questions **and** the developer has explicitly
  told you to compare. Reading the answer file in advance defeats the purpose of the quiz.

## Session State (`tasks/ARC-nnn/STATUS.md`)

Each Jira ticket has its own `tasks/ARC-nnn/STATUS.md` — the **living state
snapshot** for that ticket's branch. It records the current branch, open
subtasks, open plans, recent activity, and key context so any agent can pick
up exactly where the previous one left off.

**At the start of every session** (after reading `AGENTS.md`):
1. Identify the active ticket from the branch name (e.g., `ARC-123/my-feature` → `ARC-123`).
2. Read `tasks/ARC-nnn/STATUS.md` in full before touching any other file.
3. Cross-check the open subtasks listed there against `tasks/ARC-nnn/TODO.md` —
   if they differ, update `STATUS.md` to match `TODO.md` (the task file is authoritative).

**During a session**, update `tasks/ARC-nnn/STATUS.md` whenever:
- A subtask is completed (update Open Tasks).
- A plan file is created or significantly changed (update Open Plans).
- A significant decision or discovery is made that the next agent needs to know.

**At the end of every session** (before yielding back to the developer):
- Update the **Last Updated** timestamp and write a one-line summary.
- Update **Recent Activity** with a bullet list of key changes.
- Update **Next Steps** so the next agent knows exactly where to resume.
- Commit `tasks/ARC-nnn/STATUS.md` as part of the final commit of the session.

**What to keep in each section:**

| Section         | Contents                                                               |
|-----------------|------------------------------------------------------------------------|
| Last Updated    | ISO date + one-line session summary                                    |
| Current Branch  | Active git branch name; brief note on other local branches if relevant |
| Open Tasks      | Copy of unchecked subtasks from `TODO.md`; key files for each task     |
| Open Plans      | Table of files in `tasks/ARC-nnn/plans/` with purpose and status       |
| Recent Activity | Bullet list of meaningful changes made in the most recent session      |
| Key Context     | Decisions, design notes, or gotchas the next agent needs to understand |
| Next Steps      | Ordered list of what to do next, specific enough to act on immediately |


## Command-Line Tool Usage

- **Disable interactive paging**: When running commands that may invoke a pager (e.g., `git`, `less`, `man`, `kubectl`, etc.), always suppress paging so the command returns immediately and its output is captured. For example:
  - Use `git --no-pager <command>` for git commands.
  - Append `| cat` to commands that might page output (e.g., `kubectl ... | cat`).
  - Set `GIT_PAGER=cat` or `PAGER=cat` in the environment when needed.
  - Never rely on interactive input; all commands must run non-interactively and return their full output.

- **Never pass multi-line code via `-c` flags.** zsh mangles multi-line quoted strings
  passed to `python3 -c "..."`, `bash -c "..."`, or any other `exec -c "..."` invocation —
  unclosed inner quotes trigger `dquote>` heredoc mode, corrupting the terminal session.
  This is the same class of failure as `git commit -m "..."` (see § Git Commits).

  **The universal fix — write to a file, run the file:**

  1. Use `insert_edit_into_file` (or `create_file`) to write the code to a file.
     - Reusable scripts → `dotpy/myscript.py` (follow the `dotpy/` conventions).
     - Truly one-off scripts → `/tmp/run.py` (no need to commit).
  2. Run it:
     ```shell
     python3 dotpy/myscript.py | cat
     # or
     python3 /tmp/run.py | cat
     ```

  Additional zsh quoting rules:
  - **Single-line `-c` commands are safe** only when they contain no inner quotes and no
    `$` expansions, e.g. `python3 -c "print(42)" | cat`.
  - **Never generate file content** (RTF, XML, YAML, etc.) by echoing or printing strings
    through the shell. Write a Python script that builds the content and writes it with
    `open(...).write(...)` — this sidesteps all shell quoting entirely (see `dotpy/_gen_rtf.py`
    as a worked example).
  - **Dollar signs and backticks in double-quoted strings** are expanded by zsh; wrap them
    in single quotes or use a `$'...'` ANSI-C quote string only for truly simple one-liners.

## Task Tracking (`tasks/ARC-nnn/TODO.md` / `tasks/ARC-nnn/DONE.md`)

Each Jira ticket has its own `tasks/ARC-nnn/` directory containing:
- `TODO.md` — the active subtask checklist for that ticket
- `DONE.md` — created when all subtasks complete; moved to `archive/` with the ticket
- `STATUS.md` — living session snapshot (see § Session State above)
- `plans/` — design docs, summaries, and plan files for this ticket

**Starting a new ticket:**
```
mkdir -p tasks/ARC-nnn/plans
```
Create `tasks/ARC-nnn/TODO.md` and `tasks/ARC-nnn/STATUS.md`, then add a row
to `tasks/README.md`. Work entirely within `tasks/ARC-nnn/` — never touch
another ticket's directory or root `AGENT_*.md` files.

**`TODO.md` format** — organise work as **tasks** with **subtasks**:
```
## Task Title
Short description of the overall goal.

- [ ] Subtask one
- [ ] Subtask two
- [ ] Verify the current state of the project achieves the task goal
- [ ] Verify with the developer that the task is complete
```

- **Before executing any multi-step plan**, record it in `TODO.md` first. Do not
  begin execution until the plan is recorded so work is always resumable.
- **Check off subtasks** (`- [x]`) as they are completed.
- **Every task must end with a developer-verification subtask** as its final item.
  When reached, ask: *"Are there any additional subtasks needed before this task is complete?"*
- **Only when all subtasks are done**, create `tasks/ARC-nnn/DONE.md` with a
  timestamp, summary, and the completed checklist.

**Completing a ticket** (after PR merges, on the `agents` branch):
```shell
git mv tasks/ARC-nnn archive/ARC-nnn
```
Update `tasks/README.md` to mark the ticket archived. Commit on `agents`.

## Reordering Subtasks in `tasks/ARC-nnn/TODO.md`

**Never use string-search-and-replace to reorder tasks.** Use Python instead:

```python
import re
content = open('tasks/ARC-nnn/TODO.md').read()
parts = re.split(r'(?=^## )', content, flags=re.MULTILINE)
header, tasks = parts[0], parts[1:]
tasks.append(tasks.pop(2))  # example: move index 2 to end
open('tasks/ARC-nnn/TODO.md', 'w').write(header + ''.join(tasks))
```

## Python Utility Scripts (`dotpy/`)

- **Use existing scripts** in `dotpy/` before writing ad-hoc Python one-liners. See [`dotpy/README.md`](dotpy/README.md) for the full list and usage instructions.
- **Save reusable scripts** to `dotpy/` rather than running them once and discarding them:
  - Add a `#!/usr/bin/env python3` shebang and a module-level docstring with a **Usage** section.
  - Accept a file path as the first positional argument and fall back to stdin.
  - Add an entry to `dotpy/README.md` following the existing format.

## Git Commits

- **Never amend existing commits.** Always create a new commit on top of the current HEAD using `git commit` (not `git commit --amend`). The developer will squash or amend commits manually as needed.
- **Do not force-push** or rewrite history in any way unless the developer explicitly instructs it.
- **Never push to `main`.** Only the developer may push to the `main` branch. The agent may commit locally but must never run `git push` (or any variant that targets `main`) unless the developer explicitly instructs it.

### Writing commit messages — use `dotpy/commit.py`, never `git commit -m`

**Never use `git commit -m "..."` for multi-line messages.** zsh mangles
multi-line quoted strings and triggers heredoc mode, corrupting the terminal.

**Always use this two-step pattern instead:**

1. Use `insert_edit_into_file` (or `create_file`) to write the desired commit
   message (subject + blank line + body) to `dotpy/commit_msg.txt`.
2. Run:
   ```shell
   python3 dotpy/commit.py | cat
   ```

`dotpy/commit.py` reads `dotpy/commit_msg.txt`, writes its contents to a temp
file, and calls `git commit -F`, bypassing all shell quoting entirely.
`dotpy/commit_msg.txt` is listed in `.gitignore` and is never committed, so
`commit.py` itself never needs to be modified between uses.

Single-line subject-only commits are the **one exception** where `-m` is safe:
```shell
git commit -m "chore: single line message" | cat
```


## Pull Request Summaries

- **When the developer asks for a PR summary**, write it to `pr-summary.md` in
  the project root and open the file so they can select-all and copy from the
  editor. `pr-summary.md` is listed in `.gitignore` and will never be
  accidentally committed.
- Use standard GitHub-flavoured Markdown: `##` / `###` headings, `**bold**`,
  inline backticks, and bullet lists. Do not use HTML tags.
- Structure the summary as:
  1. **`## <Title>`** — one-line description matching the branch purpose.
  2. **`### Summary`** — 2–4 sentences on what the PR does and why.
  3. **`### Changes`** — one bold entry per changed file or directory with
     bullet sub-points explaining what changed.
  4. **`### Notes`** *(optional)* — follow-up items, known limitations, or
     things the reviewer should verify manually.
- Delete `pr-summary.md` after the PR is created; do not commit it.


## Email Drafts for Third Parties

- **When the developer asks you to compose an email** to be sent to an external party
  (e.g., ITS, HITS, a vendor, or any recipient outside the development team), write it
  as a **Rich Text Format (`.rtf`) file** so the developer can open it in any mail client
  or word processor, fill in the recipient fields, and send without reformatting.
- Save the file under **`emails/<short-descriptive-name>.rtf`**, e.g.
  `emails/its-oidc-request.rtf`, `emails/hits-elements-request.rtf`.
- The `emails/` directory is **tracked in git**. Files are committed and remain in the
  repository until the developer explicitly removes them. Do not add individual draft
  filenames to `.gitignore`.
- **RTF structure for an email draft:**
  1. `\b Subject:\b0` line
  2. `\b To:\b0` and `\b CC:\b0` lines with `[placeholder]` values the developer fills in
  3. Blank line, then the greeting and body
  4. Use `\b … \b0` for bold headings, `\f1 … \f0` (monospace/Courier) for technical values
     (client IDs, URLs, commands), and `- ` prefixed lines for bullet points
  5. Use `\par` for paragraph breaks — do **not** use `\line`, `\emdash`, `\endash`,
     `\rquote`, or other Word-specific control words; they prevent macOS TextEdit from
     opening the file
  6. A closing with `[Your name]` placeholder
- **Open the file** after creating it so the developer can review it immediately.



## Markdown Formatting

- **Format tables correctly**: Every column in a Markdown table must be padded so that all cells in that column (header, separator, and every data row) are the same width. The separator row must use dashes (`-`) at least as wide as the widest cell in each column. Mismatched widths cause IDE warnings ("Table is not correctly formatted").
  - Determine the widest cell in each column (considering the rendered source text, not the display text of links).
  - Pad every shorter cell with trailing spaces to match that width.
  - Use the same number of dashes in the separator row as the column width.
  - **The data rows — not just the header — define the required column width.** The header and separator must be padded/extended to match the widest data cell, not the other way around.
  - To auto-format a table (strip whitespace, recalculate all widths, pad in place), run: `python3 dotpy/format_table.py <file.md>` — rewrites the file with every table correctly padded. **Use this first.**
  - To compute the exact separator without editing, run: `python3 dotpy/calc_widths.py <file.md>` — it prints the maximum between-pipe width per column and the ready-to-paste separator row for every table in the file.
  - To validate alignment after editing, run: `python3 dotpy/check_tables.py <file.md>` — exits `0` if all tables are consistent, `1` with error details if not.
  - If a table requires very long lines (e.g., > 120 characters per row), prefer using a shorter link display text or a bullet-list format instead of a wide table.

## Ruby on Rails Conventions

- **Runtime environment**: All application commands must be run inside the Docker container — never against a system Ruby or Node installation. Use `docker-compose exec -- app <command>` as the prefix.
- **Code style**: RuboCop is configured with Standard, rubocop-rails, rubocop-rspec, and rubocop-rake. Before committing Ruby files, run:
  ```shell
  docker-compose exec -- app bundle exec rubocop | cat
  ```
  Auto-fix safe offences with:
  ```shell
  docker-compose exec -- app bundle exec rubocop -a | cat
  ```
- **JavaScript linting**: Uses Yarn with the `lint` script configured in `package.json`. Run:
  ```shell
  docker-compose exec -- app yarn lint | cat
  ```
- **Tests**: Two suites — MiniTest (`rake test`) and RSpec (`rspec`). Run them inside the container:
  ```shell
  docker-compose exec -- app bundle exec rake test | cat
  docker-compose exec -- app bundle exec rspec | cat
  ```
  The default CI rake task runs both: `bundle exec rake` (equivalent to `rake rubocop test spec`).
- **Running the app**: Bring up all services with `docker-compose up -d`, then start the Rails server:
  ```shell
  docker-compose exec -- app bundle exec rails s -b 0.0.0.0
  ```
  The app is available at http://localhost:3000/
- **Background jobs**: Resque workers process indexing jobs. Monitor via Resque-Web at http://localhost:8080/overview. Start workers with `docker-compose restart resque`.
- **Configuration files**: Key config locations:
  - `config/repositories.yml` — defines repository slugs, names, and metadata for each institution
  - `config/blacklight.yml` — configures the Solr connection URL per environment
  - `config/database.yml` — PostgreSQL connection config (overridden by `DATABASE_URL`)
  - `lib/dul_arclight.rb` — declares `DulArclight.finding_aid_data` (default `/data`, overridden by `FINDING_AID_DATA`)
