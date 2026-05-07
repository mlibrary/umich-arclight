# New Session Startup Prompt

> Copy and paste the block below into a new agent session, or tell the agent:

```
Read AGENT_PROMPT.md and follow the instructions there.
```

---

## Prompt

You are starting a new session in the `umich-arclight` repository — a Ruby on Rails
application that provides discovery and access for archival finding aids at the University
of Michigan Libraries. It is built on the ArcLight and Blacklight Rails engines and runs
at [https://findingaids.lib.umich.edu](https://findingaids.lib.umich.edu/).

**Before doing anything else, follow these steps in order:**

1. **Read `AGENTS.md`** — it contains the rules and conventions that govern all
   agent work in this repository. You must follow them for every action you take.

2. **Read `tasks/README.md`** — it is the task index showing what is active and
   what is archived. Then read `tasks/ARC-nnn/STATUS.md` for the active ticket
   (infer the ticket key from the current branch name, e.g. `ARC-123/my-feature` →
   `tasks/ARC-123/STATUS.md`). This tells you exactly where the previous agent
   left off.

3. **Take the onboarding quiz in `AGENT_QUIZ.md`** — answer every question by
   looking up the answer in the actual project files (do not rely on memory or
   training data). When you have answered all questions, stop and tell me:

   > "I have answered all quiz questions. Please open `AGENT_QUIZ_ANSWERS.md`
   > to grade my answers, or let me know when I may read it to self-grade."

Do not read `AGENT_QUIZ_ANSWERS.md` until I explicitly tell you to.
Do not start any development work until the quiz is complete and graded.

