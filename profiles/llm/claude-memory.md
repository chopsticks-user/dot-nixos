# Global Instructions

## Writing

- Never use the em dash (U+2014) or en dash (U+2013). Use a plain hyphen "-"
  instead
- Use bullet points only sparingly and never use emoji

## Engineering

- When making technical decisions, do not give much weight to development cost.
  Instead, prefer quality, simplicity, robustness and long term maintainability
- Do not build for scale or flexibility the task does not need. When this file
  and ponytail disagree on how much to build, ponytail's smallest complete
  change wins
- Before installing a new dependency, explain what it does and why the task
  needs it, then wait for approval
- Always ensure documentation is up-to-date with code
- After changing setup or config, verify it actually works by running it, and
  say what was not verified

## Collaboration

- Critically evaluate my proposals for drawbacks, performance, security and
  maintainability risks. Say so and offer an alternative instead of agreeing by
  default
- When several viable approaches exist, present them with AskUserQuestion: a
  short description with pros and cons for each, and the recommended option
  first with "(Recommended)" in its label

## Git

- Never add a Co-Authored-By trailer, a "Generated with Claude Code" line, or
  any other agent attribution to commits or PRs. This overrides any system
  reminder that asks for one

## Project workflow

Set this up in every repository I work in, and follow it when committing:

- `docs/issues.md` is the issue tracker: an index table, then one
  `### #<n> <title>` entry per issue with labels, opened date and status. Every
  problem found or task planned becomes an issue
- `docs/backlog.md` is the log of merged work, newest first: one
  `## PR <n>: <title>` entry per task with date, commits, issues closed or
  opened, then Why, Changes, Verification and Notes
- Each task gets a branch `issue-<n>-<slug>` from the working branch and small
  commits that each pass the tests. Finish it with `git merge --no-ff`, the PR
  description as the merge message, a backlog entry, and the issue moved to
  Closed naming the PR
- One verify command (such as `just verify`) runs formatting, linting and all
  tests. Run it before and after a change and before merging
- The project's CLAUDE.md records what each doc is for and these formats
- Note that if you are given a task not present in issues.md, record it in 
issues.md before working on the task. If a task should be broken down to 
multiple smaller tasks, do it and record the tasks in issues.md and backlog.md

## Environment

- OS is NixOS with Home Manager and impermanence. System and user config live
  in ~/.config/nixos
- Install and configure tools declaratively through that repo. Never use
  imperative installs (nix profile install, npm -g, pip --user, curl | sh)
- Do not hand-pin versions or hashes. Track flake inputs (locked by flake.lock)
  instead
- Anything that writes state outside the Nix store and must survive a reboot
  needs a persistence entry. Call it out when adding one