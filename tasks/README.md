# Task Index

Reference for the `tasks/` directory layout. For the full agent workflow and
rules, see [`AGENTS.md`](../AGENTS.md).

---

## Active Tasks

| Ticket  | Branch                                   | Summary                                                                                 |
|---------|------------------------------------------|-----------------------------------------------------------------------------------------|
| DOR-142 | `DOR-142/ingest-validation`              | Implement ingest validation (Roger Algorithm) and rename IntegrityCheck* → FixityCheck* |
| DOR-146 | `DOR-146/agent-options-and-implications` | Document agent design choices and trade-offs in dor-depot preservation metadata         |

---

## Archived Tasks

| Ticket       | Archive path | Summary |
|--------------|--------------|---------|
| *(none yet)* |              |         |

---

## Directory Convention

Each Jira ticket gets a subdirectory under `tasks/`:

```
tasks/
  DOR-nnn/
    TODO.md      ← subtask checklist (follow AGENTS.md § Task Tracking format)
    STATUS.md    ← living session snapshot (follow AGENTS.md § Session State format)
    DONE.md      ← created when all subtasks complete; retained when archived
    plans/
      *.md       ← design docs, summaries, and plan files for this ticket
```

**Starting a new ticket:**
1. `mkdir -p tasks/DOR-nnn/plans`
2. Create `tasks/DOR-nnn/TODO.md` and `tasks/DOR-nnn/STATUS.md`.
3. Add a row to the Active Tasks table above.
4. Work entirely within `tasks/DOR-nnn/` for all agent state and plans.

**Completing a ticket (after PR merges):**
1. `git mv tasks/DOR-nnn archive/DOR-nnn`
2. Move the row from Active to Archived in this file.
3. Commit on the `agents` branch.

