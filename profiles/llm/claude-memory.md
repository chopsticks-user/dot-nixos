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

Work in every repository goes through GitHub issues and pull requests (`gh`).
If a repository has no GitHub remote, ask before working around it.

1. Given a task, break it into smaller tasks when it is more than one
   reviewable change. Each task, and each problem found along the way, gets a
   GitHub issue before any work on it starts
2. Work on a branch `issue-<n>-<slug>` from the base branch: the default branch,
   unless the project's CLAUDE.md names another. Never commit directly to the
   base branch. Keep commits small, each passing the tests
3. One verify command (such as `just verify`) runs formatting, linting and all
   tests. Run it before and after a change
4. Push the branch and open a pull request against the base branch, starting
   with `Closes #<n>`, then Why, Changes, Verification and Notes
5. Review the pull request with /code-review, fix what it finds, and leave a
   PR comment listing the findings and what was fixed or left and why
6. Stop and ask me to approve. Only after my approval merge with
   `gh pr merge --merge --delete-branch`, close the issue if GitHub did not
   (it only does for the default branch), and update the local base branch

The project's CLAUDE.md records what each doc is for, the base branch if it is
not the default, and the labels in use.

## Environment

- OS is NixOS with Home Manager and impermanence. System and user config live
  in ~/.config/nixos
- Install and configure tools declaratively through that repo. Never use
  imperative installs (nix profile install, npm -g, pip --user, curl | sh)
- Do not hand-pin versions or hashes. Track flake inputs (locked by flake.lock)
  instead
- Anything that writes state outside the Nix store and must survive a reboot
  needs a persistence entry. Call it out when adding one