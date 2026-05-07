# Agent Onboarding Quiz — dor-depot

> 🚫 **DO NOT read `AGENT_QUIZ_ANSWERS.md`** until you have written out answers to all
> questions below and the developer has told you to compare. Reading the answer file
> first defeats the purpose of the quiz.
>
> **Instructions for the quiz-taker (agent):**
> Answer every question by looking it up in the actual project files — do not rely on
> memory or training data. Each question includes a hint pointing to the authoritative
> source. Write your answers in your response, then stop and prompt the developer
> (see the instruction after Q20).
>
> **Instructions for the quiz-giver (developer):**
> Run this quiz at the start of a new agent session to confirm the agent has read and
> understood the project state before it begins work. When the agent prompts you after
> Q20, open `AGENT_QUIZ_ANSWERS.md` and grade the answers yourself, or ask the agent
> to read that file and self-grade at that point.

---

## Section 1 — Ground Rules (AGENTS.md)

**Q1.** You are about to start a multi-step task. What must you do *before* executing
the first step?

*(Hint: `AGENTS.md` § Task Tracking)*

---

**Q2.** You need to reorder two subtasks in `tasks/DOR-nnn/TODO.md`. What tool must you use, and what
tool must you **never** use for this operation?

*(Hint: `AGENTS.md` § Reordering Subtasks)*

---

**Q3.** The developer asks you to amend the most recent commit to include a small fix.
What should you do instead?

*(Hint: `AGENTS.md` § Git Commits)*

---

**Q4.** You need to run a short multi-line Python snippet. Your first instinct is to
write `python3 -c "..."`. What is wrong with that approach in this environment, and
what is the universal fix?

*(Hint: `AGENTS.md` § Command-Line Tool Usage)*

---

**Q5.** After editing a Markdown file that contains tables, what two commands should
you run before committing, in order?

*(Hint: `AGENTS.md` § Markdown Formatting)*

---

**Q6.** Before committing changes to Java source files, what Gradle task should you run
to auto-fix formatting, and what task confirms there are no remaining style violations?
Write the exact commands as you would type them in the terminal, including any suffix
needed to ensure output is captured without a pager.

*(Hint: `AGENTS.md` § Java / Gradle Conventions and § Command-Line Tool Usage)*

---

## Section 2 — Project Structure and Build

**Q7.** What Java version does this project require?

*(Hint: `build.gradle` — look for the `toolchain` block)*

---

**Q8.** What is the main class of the application (the entry point Spring Boot will bootstrap)?

*(Hint: `build.gradle` — look for `springBoot { mainClass = ... }`)*

---

**Q9.** Name the Spring Modulith modules in this project (by their Java package names
relative to `edu.umich.lib.dor.depot`).

*(Hint: `src/main/java/edu/umich/lib/dor/depot/` — identify the sub-packages that represent Modulith modules, excluding support packages such as `config` if they are not modules)*

---

**Q10.** What are the three application-specific path properties defined in
`src/main/resources/application.properties`? Give the property key and its default value
for each.

*(Hint: `src/main/resources/application.properties`)*

---

**Q11.** What two infrastructure services does the application require at runtime, and
how are they managed in the local development environment?

*(Hint: `compose.yaml`; `README.md` § Usage)*

---

**Q12.** What command starts the application as a running service?
What command runs the full JUnit test suite?

*(Hint: `README.md` § Usage)*

---

## Section 3 — Domain Concepts and Object Lifecycle

**Q13.** What is a "Curio"? Describe its directory structure precisely — name the
directories involved and what kind of file lives in each. Where can you find a
concrete example of a Curio in the repository?

*(Hint: `README.md` § Development — Ingesting Curios; inspect the fixture at
`src/test/resources/inbox/e145de0c-8ffb-49fc-af26-c5b735622b3e`;
`src/main/java/edu/umich/lib/dor/depot/preservation/HeaderFileUtility.java`)*

---

**Q14.** `AdminController` exposes four `POST` endpoints under `/admin`.
Name all four paths, the query parameter(s) each accepts, and the Spring
Modulith event each one publishes.

*(Hint: `src/main/java/edu/umich/lib/dor/depot/console/AdminController.java`)*

---

**Q15.** Trace the **complete** event flow that occurs after `POST /admin/submit` is called
with a `packageId`. Name each Spring Modulith event and the service class that handles it,
in order — including any events published on the **error path**.

*(Hint: `src/main/java/edu/umich/lib/dor/depot/console/AdminController.java`;
`src/main/java/edu/umich/lib/dor/depot/preservation/PackageImportService.java`;
`src/main/java/edu/umich/lib/dor/depot/preservation/IntakeService.java`)*

---

**Q16.** What storage format does `OcflPreservationGateway` use to persist digital objects,
and what layout algorithm does it use when building the repository on disk?

*(Hint: `src/main/java/edu/umich/lib/dor/depot/preservation/OcflPreservationGateway.java`)*

---

**Q17.** `IntakeService.process()` stages and then optionally commits changes depending on
a field in the submission label. What is that field, and what value triggers an immediate
commit?

*(Hint: `src/main/java/edu/umich/lib/dor/depot/preservation/IntakeService.java`)*

---

## Section 4 — Active Work and Task Management

**Q18.** Look at `tasks/README.md`. List every currently active ticket with its key and a
one-sentence summary of what it is working on.

*(Hint: `tasks/README.md` and each active `tasks/DOR-nnn/STATUS.md`)*

---

**Q19.** A task in `tasks/DOR-nnn/TODO.md` has all subtasks checked off including the developer-verification
subtask. What are the steps required to archive it, and where does the task directory move to?

*(Hint: `AGENTS.md` § Task Tracking)*

---

## Section 5 — Reset and Maintenance

**Q20.** How do you fully reset the local development environment (clear the OCFL repository
**and** the database) so the application starts from a clean state?
List each step in order.

*(Hint: `README.md` § Development — Ingesting Curios)*

---

## Section 6 — Submission Packaging

**Q21.** Every submission package must contain a label file at its root. What is
that file called, and what are its six required fields (give the exact key names
as they appear in the file)?

*(Hint: `src/main/java/edu/umich/lib/dor/depot/preservation/SubmissionLabel.java`;
inspect `src/test/resources/inbox/e145de0c-8ffb-49fc-af26-c5b735622b3e/dor-info.txt`)*

---

**Q22.** What are the three valid values for the `Resource-Type` field in `dor-info.txt`?
Give both the string value written in the file and the enum constant name for each.

*(Hint: `src/main/java/edu/umich/lib/dor/depot/preservation/ResourceType.java`)*

---

**Q23.** What are the two valid values for the `Action` field in `dor-info.txt`?
Describe the behavioural difference: what happens to OCFL changes when each value
is used during ingest?

*(Hint: `src/main/java/edu/umich/lib/dor/depot/preservation/SubmissionAction.java`;
`src/main/java/edu/umich/lib/dor/depot/preservation/IntakeService.java` lines 83–86)*

---

**Q24.** After `IntakeService` publishes `BinContentsModified`, what service handles
that event? What does it do, and what event does it publish when it completes
successfully?

*(Hint: `src/main/java/edu/umich/lib/dor/depot/preservation/CatalogService.java`)*

---

**Q25.** `POST /admin/publish` triggers a `PublishDraft` event. What service handles
`PublishDraft`, and what are **all possible outcomes** — describe every code path,
including the case where no event is published at all.

*(Hint: `src/main/java/edu/umich/lib/dor/depot/preservation/DraftPublicationService.java`)*

---

**Q26.** What are the four database tables created by `schema.sql`?
Give the table name and a one-sentence description of what each one stores.

*(Hint: `src/main/resources/schema.sql`)*

---

**Q27.** `IntegrityService` handles two different commands. For each one,
name the command, the gateway method it calls, and all possible outcome events
(success, failure, and missing-object cases).

*(Hint: `src/main/java/edu/umich/lib/dor/depot/preservation/IntegrityService.java`)*

---

**Q28.** The console web UI is served by `ObjectController` at the `/console`
prefix. It has four `GET` endpoints. Name all four paths and state what each one
does (what it renders or streams).

*(Hint: `src/main/java/edu/umich/lib/dor/depot/console/ObjectController.java`)*

---

**Q29.** `WorkingStorage.importPackage()` copies a package directory into working
storage and returns a `SubmissionId`. What static method generates the
`SubmissionId`, and what class reads and validates the package's label from disk?

*(Hint: `src/main/java/edu/umich/lib/dor/depot/preservation/WorkingStorage.java`;
`src/main/java/edu/umich/lib/dor/depot/preservation/SubmissionLabel.java`)*

---

**Q30.** Cross-module communication in this Spring Modulith application must go
through published application events. However, the `console` module does directly
inject two beans from the `preservation` module in `ObjectController`. Name those
two beans, and explain why this is intentional (what kind of operations do they
serve versus what goes through events)?

*(Hint: `src/main/java/edu/umich/lib/dor/depot/console/ObjectController.java`;
`AGENTS.md` § Java / Gradle Conventions — Module boundaries)*

---

## When You Have Answered All 30 Questions

Stop here. Do **not** open `AGENT_QUIZ_ANSWERS.md`.

Tell the developer:

> "I have answered all 30 quiz questions. Please open `AGENT_QUIZ_ANSWERS.md` to grade
> my answers, or let me know when I may read it to self-grade."

Wait for the developer's instruction before proceeding.
