# Agent Onboarding Quiz — umich-arclight

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

**Q2.** You need to reorder two subtasks in `tasks/ARC-nnn/TODO.md`. What tool must you use, and what
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

## Section 2 — Project Stack and Build

**Q6.** What Ruby version does this project use?

*(Hint: `Dockerfile` — look for the `FROM ruby:` line)*

---

**Q7.** What Rails version does this project require?

*(Hint: `Gemfile`)*

---

**Q8.** In local development, what localhost port is mapped for each core Docker
service (`app`, `db`, `solr`, `redis`)?

*(Hint: `docker-compose.yml`)*

---

**Q9.** What command do you run to start the Rails development server (inside the
container), and at what URL is the application available?

*(Hint: `README.md` § Development Quick Start)*

---

**Q10.** What are the two test suites in this project, the rake task for each, and what
single rake command runs *all* of them (plus linting)?

*(Hint: `README.md` § Continuous Integration; `lib/tasks/default.rake`)*

---

**Q11.** Before committing Ruby source files, what command auto-fixes RuboCop offences,
and what command reports remaining violations? Write both as full `docker-compose exec`
invocations.

*(Hint: `AGENTS.md` § Ruby on Rails Conventions; `README.md` § Ruby Linting)*

---

## Section 3 — Domain Concepts

**Q12.** What is this application, and what XML format does it use for archival finding
aid data? Where does the application store that data, and which environment variable
overrides the default path?

*(Hint: `README.md`; `lib/dul_arclight.rb`; `Dockerfile`)*

---

**Q13.** List every repository slug defined in `config/repositories.yml` and give the
human-readable institution name for each.

*(Hint: `config/repositories.yml` — look for top-level keys)*

---

**Q14.** What Rake task indexes *all* EAD files for all repositories at once?
What Rake task indexes just one repository's files? Write both as full
`docker-compose exec` invocations and name the environment variables each one accepts.

*(Hint: `README.md` § Indexing EAD Files; `lib/tasks/reindex.rake`)*

---

**Q15.** What Rake task indexes a single EAD file? Write the full `docker-compose exec`
invocation with example values for the required environment variables.

*(Hint: `README.md` § Indexing EAD Files)*

---

**Q16.** What environment variable controls whether the finding aid ingest UI
(`/findingaids`, `/slugmaps`) is enabled? Where is this variable set in the
development environment?

*(Hint: `config/routes.rb`; `docker-compose.yml`)*

---

## Section 4 — Active Work and Task Management

**Q17.** Look at `tasks/README.md`. List every currently active ticket with its key and a
one-sentence summary of what it is working on.

*(Hint: `tasks/README.md` and each active `tasks/ARC-nnn/STATUS.md`)*

---

**Q18.** A task in `tasks/ARC-nnn/TODO.md` has all subtasks checked off including the
developer-verification subtask. What are the steps required to archive it, and where
does the task directory move to?

*(Hint: `AGENTS.md` § Task Tracking)*

---

## Section 5 — Reset and Maintenance

**Q19.** How do you fully recreate the development database from scratch? List the exact
commands in order.

*(Hint: `README.md` § Setup databases)*

---

**Q20.** How do you delete and recreate a Solr core (e.g. `umich-arclight-test`)?
List the exact commands in order.

*(Hint: `README.md` § Create solr cores)*

---

## When You Have Answered All 20 Questions

Stop here. Do **not** open `AGENT_QUIZ_ANSWERS.md`.

Tell the developer:

> "I have answered all 20 quiz questions. Please open `AGENT_QUIZ_ANSWERS.md` to grade
> my answers, or let me know when I may read it to self-grade."

Wait for the developer's instruction before proceeding.
