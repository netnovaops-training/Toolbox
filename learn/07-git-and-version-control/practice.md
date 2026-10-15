> **what:** git practice — exercises to make the model stick
> **status:** trying
> **tags:** git, practice, foundational
> **last-used:** 2026-10-15

# Git practice

Do these in a **throwaway folder** (`mkdir ~/git-practice && cd ~/git-practice`),
not in a real repo. Hints only — work them out; ask your mentor if stuck.

1. **Start fresh.** Make a new folder, `git init`, create a file, and get it to
   show as "committed". *Hint: the loop is add → commit. `git status` after each step.*

2. **Read the states.** Edit the file but don't add it. Run `git status`. Now
   `git add` it, run `git status` again. Describe in your own words what changed.
   *Hint: untracked/modified → staged.*

3. **See a diff.** Change two lines, then show exactly what changed before staging.
   *Hint: one command, starts with `git d`.*

4. **Good messages.** Make three commits with messages that say *what* in a few
   words (not "update", not "stuff"). *Hint: imperative mood — "Add…", "Fix…".*

5. **Branch and switch.** Make a branch, add a commit on it, switch back to `main`,
   and confirm the change isn't there. Then switch back to the branch and confirm
   it is. *Hint: `git switch -c name`, then `git switch main`.*

6. **Merge.** Merge your branch into `main` and look at `git log --oneline`.
   *Hint: be on `main` first, then `git merge <branch>`.*

7. **Undo a staging.** Stage a file, then un-stage it without losing your edits.
   *Hint: `git restore --staged <file>` — check `git status` before and after.*

8. **Where have I been?** Run `git reflog` and read it. When would this save you?
   *Hint: it lists every place HEAD has pointed — your safety net.*

**Check yourself:** can you explain, out loud, the difference between `add`,
`commit`, and `push` — and why a commit is still "yours" before you push?
