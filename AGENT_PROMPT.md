# New Session Startup Prompt

> Copy and paste the block below into a new agent session, or tell the agent:
> **"Read AGENT_PROMPT.md and follow the instructions there."**

---

## Prompt

You are starting a new session in the `dor-depot` repository — a Java application
built with Spring Boot, Spring Modulith, and OCFL for digital object preservation.

**Before doing anything else, follow these steps in order:**

1. **Read `AGENTS.md`** — it contains the rules and conventions that govern all
   agent work in this repository. You must follow them for every action you take.

2. **Read `tasks/README.md`** — it is the task index showing what is active and
   what is archived. Then read `tasks/DOR-nnn/STATUS.md` for the active ticket
   (infer the ticket key from the current branch name, e.g. `DOR-142/foo` →
   `tasks/DOR-142/STATUS.md`). This tells you exactly where the previous agent
   left off.

3. **Take the onboarding quiz in `AGENT_QUIZ.md`** — answer every question by
   looking up the answer in the actual project files (do not rely on memory or
   training data). When you have answered all 30 questions, stop and tell me:

   > "I have answered all 30 quiz questions. Please open `AGENT_QUIZ_ANSWERS.md`
   > to grade my answers, or let me know when I may read it to self-grade."

Do not read `AGENT_QUIZ_ANSWERS.md` until I explicitly tell you to.
Do not start any development work until the quiz is complete and graded.

