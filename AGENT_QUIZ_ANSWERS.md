# Agent Onboarding Quiz — Answer Key

> ⚠️ **DO NOT READ THIS FILE** until you have answered all 30 questions in
> `AGENT_QUIZ.md` and the developer has told you to compare your answers.
> Reading this file before completing the quiz defeats its purpose.

---

> Every answer below can be verified by reading the cited source file.
> If an answer here contradicts what you find in the source, **the source file wins**.

---

**A1.** Add the plan to `tasks/DOR-nnn/TODO.md` as a new task with subtasks before taking any action.
Do not begin execution until the plan is recorded.
*(Source: `AGENTS.md` § Task Tracking — "Before executing any multi-step plan, record it in `TODO.md` first")*

---

**A2.** Always use **Python** (`re.split` on `## ` headings, reorder list, rewrite file).
Never use **string-search-and-replace** — task bodies contain long text that makes
patterns brittle and prone to corrupting the file.
*(Source: `AGENTS.md` § Reordering Subtasks in `tasks/DOR-nnn/TODO.md`)*

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

**A6.**
1. `./gradlew spotlessApply | cat` — auto-fixes formatting issues in Java source files
2. `./gradlew spotlessCheck | cat` — confirms there are no remaining style violations

The `| cat` suffix is required by the AGENTS.md paging rule: all commands that may invoke
a pager must suppress it so output is captured without waiting for user input.

*(Source: `AGENTS.md` § Java / Gradle Conventions; § Command-Line Tool Usage — "Disable interactive paging")*

---

**A7.** Java **26** (Eclipse Temurin 26 or compatible OpenJDK 26 distribution).
*(Source: `build.gradle` — `java { toolchain { languageVersion = JavaLanguageVersion.of(26) } }`)*

---

**A8.** `edu.umich.lib.dor.depot.DepotApplication`
*(Source: `build.gradle` — `springBoot { mainClass = 'edu.umich.lib.dor.depot.DepotApplication' }`)*

---

**A9.** There are two Spring Modulith application modules with Spring-managed beans:
1. **`preservation`** — (`edu.umich.lib.dor.depot.preservation`) — handles OCFL storage, ingest, integrity checks
2. **`console`** — (`edu.umich.lib.dor.depot.console`) — the web UI / admin REST layer

A third top-level package, **`config`**, exists and is detected by Spring Modulith
(a `module-config.adoc` is generated for it), but it contains only a MyBatis
`UuidTypeHandler` annotated with `@MappedTypes` — it has no Spring-managed beans and
is a support/infrastructure package, not an application module.

*(Source: `src/main/java/edu/umich/lib/dor/depot/` — sub-package structure;
`build/spring-modulith-docs/module-config.adoc`)*

---

**A10.**
| Property key              | Default value          |
|---------------------------|------------------------|
| `dor.workingStorage.path` | `data/working-storage` |
| `dor.inbox.path`          | `data/inbox`           |
| `dor.ocfl.path`           | `data/ocfl`            |

*(Source: `src/main/resources/application.properties` lines 13–15)*

---

**A11.** **PostgreSQL** (relational database) and **RabbitMQ** (message broker).
In local development they are started automatically by Spring Boot's Docker Compose
integration (`spring-boot-docker-compose`) using the `compose.yaml` file at the project
root. Docker Desktop must be running before starting the application or tests.
*(Source: `compose.yaml`; `README.md` § Usage — "the application itself and tests use Docker containers for PostgreSQL and RabbitMQ")*

---

**A12.**
- Start the application: `./gradlew bootRun`
- Run the test suite: `./gradlew test`

*(Source: `README.md` § Usage)*

---

**A13.** A **Curio** is a digital object package with the following structure:

- `dor-info.txt` — label file at the package root (required fields described in Q21)
- `data/` — directory containing the content files
- `data/.dor/` — subdirectory containing a JSON sidecar file for each content file
  (named `<filename>.json`), carrying the file's SHA-512 digest and other metadata

Each content file in `data/` must have a corresponding `.json` sidecar in
`data/.dor/`. The `HeapOfFilesSubmissionReader` enforces this: it walks `data/`,
filters out `.dor/` files, and requires a header file for every content file.

A concrete example is the test fixture at:
`src/test/resources/inbox/e145de0c-8ffb-49fc-af26-c5b735622b3e`

*(Source: `README.md`; `HeaderFileUtility.java`; `HeapOfFilesSubmissionReader.java`;
fixture at `src/test/resources/inbox/e145de0c-8ffb-49fc-af26-c5b735622b3e`)*

---

**A14.** `AdminController` exposes four `POST` endpoints:

| Path                            | Query parameters                                   | Event published           |
|---------------------------------|----------------------------------------------------|---------------------------|
| `POST /admin/submit`            | `packageId`                                        | `PackageSubmitted`        |
| `POST /admin/publish`           | `objectId`, `agentName`, `agentAddress`, `message` | `PublishDraft`            |
| `POST /admin/integrity-check`   | `objectId`, `agentName`, `agentAddress`            | `PerformFixityCheck`      |
| `POST /admin/ingest-validation` | `objectId`, `agentName`, `agentAddress`            | `PerformIngestValidation` |

*(Source: `src/main/java/edu/umich/lib/dor/depot/console/AdminController.java`)*

---

**A15.** Complete event flow after `POST /admin/submit`:

**Happy path:**
1. `AdminController.submit()` publishes **`PackageSubmitted`** (carrying the `PackageId`).
2. `PackageImportService.on(PackageSubmitted)` handles it: reads the package from the inbox,
   moves it to working storage, and publishes **`SubmissionReceived`** (carrying the `SubmissionId`).
3. `IntakeService.on(SubmissionReceived)` handles it: runs `process()` — builds the changeset,
   transforms the submission, stages/commits it to the OCFL repository, generates descriptors,
   logs the preservation event, and publishes **`BinContentsModified`**.

**Error path:**
If `process()` throws a `SubmissionReadException`, `IntakeService` catches it and publishes
**`SubmissionRejected`** (carrying the `SubmissionId` and error message) instead of `BinContentsModified`.

A complete answer must name all four events: `PackageSubmitted`, `SubmissionReceived`,
`BinContentsModified`, and `SubmissionRejected`.

*(Source: `AdminController.java`; `PackageImportService.java`; `IntakeService.java`)*

---

**A16.** `OcflPreservationGateway` uses the **OCFL** (Oxford Common File Layout) standard
for storing digital objects. The repository is built with the **Hashed N-Tuple storage layout**
(`HashedNTupleLayoutConfig`), which distributes objects across a hash-based directory tree.
*(Source: `src/main/java/edu/umich/lib/dor/depot/preservation/OcflPreservationGateway.java` —
constructor, `new OcflRepositoryBuilder().defaultLayoutConfig(new HashedNTupleLayoutConfig())`)*

---

**A17.** The field is `action` (obtained via `label.getAction()`), which is of type
`SubmissionAction`. The value `SubmissionAction.Commit` triggers an immediate
`preservationGateway.commitChanges()` call. If the action is anything other than `Commit`,
changes are staged but not committed.
*(Source: `src/main/java/edu/umich/lib/dor/depot/preservation/IntakeService.java` lines 84–86)*

---

**A18.** *(Answer by reading `tasks/README.md` and the relevant `tasks/DOR-nnn/STATUS.md` at the
time the quiz is taken — the active task list changes over time. The agent must look up the
current state, not rely on memory.)*

*(Source: `tasks/README.md`, `tasks/DOR-nnn/STATUS.md`)*

---

**A19.**
1. Create `tasks/DOR-nnn/DONE.md` with a timestamp, summary, and the completed checklist.
2. Run `git mv tasks/DOR-nnn archive/DOR-nnn` on the `agents` branch.
3. Update `tasks/README.md` to mark the ticket archived.
4. Commit on `agents`.

The completed ticket directory moves to **`archive/DOR-nnn/`**.
*(Source: `AGENTS.md` § Task Tracking — "Completing a ticket (after PR merges, on the `agents` branch)")*

---

**A20.** Three steps, in order:
1. Delete the contents of `data/ocfl/root` (clears the OCFL repository).
2. Run `docker compose down` (shuts down the running PostgreSQL container).
3. Run `docker volume rm dor-depot_postgres-data` (removes the PostgreSQL data volume
   so the schema is re-created fresh on next startup).

*(Source: `README.md` § Development — Ingesting Curios)*

---

## Section 6 — Submission Packaging

**A21.** The label file is **`dor-info.txt`**, placed at the package root.
Its six required fields (key: value, one per line) are:

| Key               | Purpose                                           |
|-------------------|---------------------------------------------------|
| `Root-Identifier` | The identifier for the OCFL object (BinId)        |
| `Resource-Type`   | Type of resource (`Curio`, `Glam`, etc.)          |
| `Action`          | `Commit` or `Stage`                               |
| `Agent-Name`      | Display name of the depositing agent              |
| `Agent-Address`   | Address (e.g. `mailto:…`) of the depositing agent |
| `Version-Message` | Human-readable description of the version         |

Example from the Curio fixture:
```
Root-Identifier: f35891e4-1cca-4fdb-9021-b3914a90dfb3
Resource-Type: Curio
Action: Commit
Agent-Name: Jill
Agent-Address: mailto:jill@example.edu
Version-Message: Adding some content
```

*(Source: `SubmissionLabel.java`; `LabelProperty.java`;
`src/test/resources/inbox/e145de0c-8ffb-49fc-af26-c5b735622b3e/dor-info.txt`)*

---

**A22.** Three valid `Resource-Type` values:

| Enum constant          | String value written in `dor-info.txt`          |
|------------------------|-------------------------------------------------|
| `ResourceType.CURIO`   | `Curio`                                         |
| `ResourceType.GLAM`    | `urn:umich:lib:dor:model:2026:resource:glam`    |
| `ResourceType.FILESET` | `urn:umich:lib:dor:model:2026:resource:fileset` |

*(Source: `src/main/java/edu/umich/lib/dor/depot/preservation/ResourceType.java`)*

---

**A23.** Two valid `Action` values:

- **`Commit`** — `IntakeService` stages all changes to the OCFL object *and* immediately calls
  `preservationGateway.commitChanges()`, creating a new immutable OCFL version.
- **`Stage`** — `IntakeService` stages changes only; the mutable staged state is left open.
  A subsequent `POST /admin/publish` (`PublishDraft` event handled by `DraftPublicationService`)
  is required to commit the staged changes.

*(Source: `SubmissionAction.java`; `IntakeService.java` lines 83–86)*

---

**A24.** `CatalogService.on(BinContentsModified)` handles the event. It:
1. Reads `descriptor.json` from the OCFL object at the indicated version.
2. Parses it into a `DescriptorResource` tree.
3. Uses `Cataloger` to write `Resource`, `ResourceSnapshot`, and `ResourceFile` records
   to the PostgreSQL database.
4. Loads preservation events from OCFL log files and saves them to the database.
5. Publishes **`RepresentationCataloged`** (carrying `RepresentationId`, resource id,
   and snapshot id).

*(Source: `src/main/java/edu/umich/lib/dor/depot/preservation/CatalogService.java`)*

---

**A25.** `DraftPublicationService.on(PublishDraft)` handles the event. It:
1. Checks whether the OCFL object exists *and* has staged changes.
   If neither condition is met, it returns immediately (no-op).
2. Calls `preservationGateway.commitChanges()` to create a new immutable OCFL version.
3. On success, publishes **`BinContentsModified`** (which then triggers `CatalogService`
   to update the database catalog).
4. On failure (e.g. object not found), publishes **`PublicationFailed`** instead.

*(Source: `src/main/java/edu/umich/lib/dor/depot/preservation/DraftPublicationService.java`)*

---

**A26.** Four tables in `schema.sql`:

| Table name                   | Stores                                                       |
|------------------------------|--------------------------------------------------------------|
| `catalog_resource`           | A unique digital object (identifier, type, UUID)             |
| `catalog_resource_snapshot`  | A versioned snapshot of a resource (title, draft flag, etc.) |
| `catalog_resource_file`      | A file attached to a snapshot (path, format, size, digest)   |
| `catalog_preservation_event` | A PREMIS preservation event (type, outcome, agents, objects) |

*(Source: `src/main/resources/schema.sql`)*

---

**A27.** `IntegrityService` handles two commands:

**`PerformFixityCheck`** (listener: `on(PerformFixityCheck)`):
Calls `preservationGateway.checkFixity()` (OCFL object validation) and publishes one of:
- **`FixityCheckPassed`** — object validated successfully (no errors).
- **`FixityMismatchDetected`** — validation returned errors (fixity failure).
- **`FixityCheckTargetMissing`** — object does not exist (`PreservationNotFoundException` caught).

**`PerformIngestValidation`** (listener: `on(PerformIngestValidation)`):
Iterates all `.dor/` sidecar files, compares each sidecar's recorded inbox digest against
the OCFL manifest digest (via `getContentFileDigests()`), writes a PREMIS `VALIDATION`
event, and publishes one of:
- **`IngestValidationPassed`** — all sidecar digests match the OCFL manifest.
- **`IngestValidationDiscrepancyDetected`** — one or more digest mismatches found,
  or no sidecar files exist in the object.
- **`IngestValidationTargetMissing`** — object does not exist (`PreservationNotFoundException` caught).

In all cases the result is written as a PREMIS preservation event to OCFL log files and
to the database.

*(Source: `src/main/java/edu/umich/lib/dor/depot/preservation/IntegrityService.java`)*

---

**A28.** `ObjectController` serves four `GET` endpoints under `/console`:

| Path                                                       | Does what                                                                           |
|------------------------------------------------------------|-------------------------------------------------------------------------------------|
| `GET /console/objects/`                                    | Renders a paginated list of all root resource snapshots                             |
| `GET /console/objects/{id}/`                               | Renders a detail view for a single object snapshot (with events)                    |
| `GET /console/objects/{id}/versions/`                      | Renders the version history for the resource owning snapshot `{id}`                 |
| `GET /console/objects/{objectId}/files/{fileId}/download/` | Streams a file from the OCFL repository directly to the HTTP response (no template) |

*(Source: `src/main/java/edu/umich/lib/dor/depot/console/ObjectController.java`)*

---

**A29.** `SubmissionId.generate()` (a static factory method) creates a new random UUID
wrapped in a `SubmissionId`. The submission's label is read by constructing a
`SubmissionLabel(submissionId, submissionDirectory)`, which opens `dor-info.txt` in
the submission directory, parses the key-value pairs, validates all required fields are
present, and throws a typed exception if any are missing or malformed.

*(Source: `WorkingStorage.java`; `SubmissionLabel.java`)*

---

**A30.** `ObjectController` directly injects **`CatalogService`** and
**`PreservationGateway`** from the `preservation` module. This is intentional:

- **Read-only query operations** (browsing objects, viewing versions, downloading files)
  go directly through these beans — they are synchronous, read-only, and have no
  side-effects on preserved content.
- **Write operations** (ingest, publish, integrity check) go through published
  Spring Modulith events so they can be externalized to RabbitMQ, retried, and
  processed asynchronously across module boundaries.

The direct injection pattern is acceptable here because `ObjectController` never
mutates preservation state; it only reads catalog data and streams file content.

*(Source: `ObjectController.java`; `AGENTS.md` § Java / Gradle Conventions —
Module boundaries)*
