# Agent rules

## Workflow
- Work in a git worktree on its own branch, never in the main checkout.
- Plan first for anything beyond a one-line change. State the plan in 3-5 bullets.
- Make small changes. Run the tests or the app after each one.
- Do not claim done without showing real command output.

## Style
- No em dashes. Direct tone. No filler in code comments or docs.
- Prefer boring, readable code over clever code.
- Do not add dependencies without saying why.

## Safety
- Never commit secrets, tokens, or .env files.
- Ask before destructive actions: force push, history rewrite, deleting data.
- Verify facts against primary sources. Label what is unverified.

## Handoff
- End each task with: what changed, what is verified, what is left.

## Skills
Project skills are in `.claude/skills/<name>/SKILL.md`. Load the matching one before starting.
