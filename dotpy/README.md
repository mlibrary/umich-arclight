# dotpy — Python Utility Scripts

This directory contains small Python helper scripts used by developers and AI
coding agents working in this repository.  All scripts require only the Python
standard library (no `pip install` needed) and are invoked directly with
`python3`.

---

## Scripts

### `commit.py` — Safe multi-line git commit helper

Reads a commit message from `dotpy/commit_msg.txt` and calls `git commit -F`,
bypassing all shell quoting. This avoids the zsh heredoc-mode bug that occurs
when using `git commit -m "..."` with multi-line strings.

`dotpy/commit_msg.txt` is listed in `.gitignore` and is never committed, so
`commit.py` itself never needs to be modified between uses.

**Usage (per `AGENTS.md` § Git Commit Messages)**

1. Use `insert_edit_into_file` (or `create_file`) to write the desired commit
   message to `dotpy/commit_msg.txt` (subject line + blank line + body).
2. Run:
   ```shell
   python3 dotpy/commit.py | cat
   ```

The script reads `dotpy/commit_msg.txt`, writes its contents to a temp file via
`tempfile.NamedTemporaryFile`, calls `git commit -F <tempfile>`, then deletes
the temp file. It exits with an error if `commit_msg.txt` is missing or empty.

**When to use**

- Every time a multi-line commit message is needed. `git commit -m` with
  multi-line strings is **never** safe in zsh — always use this script instead.
- Single-line subject-only commits may still use `git commit -m "subject" | cat`.

---

### `calc_widths.py` — Markdown table column-width calculator

Reads a Markdown file (or stdin) and, for every table found, prints the maximum
between-pipe cell width for each column and a correctly sized separator row.

**Usage**

```shell
python3 dotpy/calc_widths.py <file.md>
python3 dotpy/calc_widths.py          # reads from stdin
```

**Example output**

```
Table at line 23 — 3 col(s), between-pipe widths: 33  8  11
Separator: |---------------------------------|--------|-----------|
```

**When to use**

- When authoring a new Markdown table: draft the rows first, run this script,
  then paste in the printed separator and pad every cell to the reported widths.
- When a table has grown (new rows with wider content): re-run to get updated
  widths and separator, then widen existing cells accordingly.

---

### `check_tables.py` — Markdown table column-width validator

Reads a Markdown file (or stdin) and checks that every row in every table —
header, separator, and data rows — has the same between-pipe column widths.
Reports any mismatches with file name and line number.

**Usage**

```shell
python3 dotpy/check_tables.py <file.md>
python3 dotpy/check_tables.py          # reads from stdin
```

**Exit codes:** `0` = all tables pass, `1` = one or more errors found.

**Example output (error)**

```
ERROR: README.md:67 col 3: width mismatch (header=32, this row=28)
  Row: '| http://localhost:8080/server | backend | Server API |'
```

**When to use**

- After editing any Markdown table, run to confirm nothing is misaligned.
- In CI or pre-commit hooks to catch formatting regressions automatically.

---

### `format_table.py` — Auto-format Markdown tables in place

Reads a Markdown file (or stdin), strips unnecessary whitespace from every
table cell, recalculates column widths, and rewrites the file with all tables
correctly padded.  Alignment markers (`:`) in separator rows are preserved.

**Usage**

```shell
python3 dotpy/format_table.py <file.md>   # formats in place
python3 dotpy/format_table.py             # reads from stdin, writes to stdout
```

**When to use**

- After writing or editing a Markdown table without worrying about alignment —
  run this script and the table is padded automatically.
- Faster than running `calc_widths.py` and padding cells by hand.
- Follow up with `check_tables.py` to confirm the result is valid.

---

### `_gen_rtf.py` — RTF email draft generator (internal helper)

Generates `emails/its-oidc-request.rtf` — a macOS TextEdit-compatible RTF draft
for the ITS OIDC client request. Used as the canonical worked example of generating
structured file content from Python without any shell quoting (per `AGENTS.md`
§ Command-Line Tool Usage).

**Usage**

```shell
python3 dotpy/_gen_rtf.py
```

Takes no arguments. Output path is hardcoded to `emails/its-oidc-request.rtf`
relative to the project root.

**When to use**

- As a template when writing a new email draft generator script.
- Never echo RTF content through the shell — always write it from Python.

---

## Conventions for adding new scripts

When a new Python utility is useful enough to save for future use, add it here:

1. Place the `.py` file in this `dotpy/` directory.
2. Add a `#!/usr/bin/env python3` shebang and a module-level docstring that
   includes a **Usage** section and a brief description of what the script does.
3. Accept an input path appropriate to the tool (file or directory) as the first
   positional argument, and/or fall back to stdin when applicable, so the script
   is composable with pipes where that makes sense.
4. Add an entry to this README under the **Scripts** section following the same
   format: script name, one-line description, Usage block, example output, and
   a "When to use" note.
5. Reference the script from `AGENTS.md` if coding agents should know about it.
