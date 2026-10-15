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

## Harder — the stuff that comes up on the job

Still a throwaway folder. These are the moves interviewers ask about.

9. **Cause a merge conflict on purpose, then resolve it.** Commit a file on `main`.
   Branch off, change one line, commit. Switch back to `main`, change the *same* line
   differently, commit. Merge the branch. When it stops, open the file, make it say
   what you want (remove the marker lines), then finish. *Hint: `git status` lists the
   "both modified" file; after editing it's `git add` then `git commit`. Scared?
   `git merge --abort` backs all the way out.*

10. **Read the conflict markers.** In that conflict, before you fix it, find the three
    markers in the file and say out loud which side is which. *Hint: `<<<<<<< HEAD` is
    the branch you're merging INTO; below `=======` is the branch coming in.*

11. **Write a `.gitignore`.** Create a `*.log` file and a `secret.env` file, then write
    a `.gitignore` so neither shows up in `git status`. Confirm only `.gitignore` is
    offered to commit. *Hint: one pattern per line; a trailing `/` means a folder.*

12. **Oops — I committed a secret.** Commit `secret.env` *first*, then add it to
    `.gitignore`. Notice git still tracks it. Make git stop tracking it without deleting
    your file. *Hint: `git rm --cached secret.env`, then commit. (In real life you'd
    also rotate the secret — history still remembers it.)*

13. **Undo a commit two ways.** Make a commit with a sloppy message. Un-commit it but
    keep the change staged, then re-commit with a good message. *Hint: `git reset --soft
    HEAD~1`.* Then make another commit and undo it the *safe* way that leaves history
    intact. *Hint: `git revert` makes a new undo-commit — use this on anything shared.*

14. **Read a diff between two commits.** Using `git log --oneline`, pick two commit
    hashes and show exactly what changed between them. Say which lines were added and
    which removed. *Hint: `git diff <older> <newer>`; `-` is removed, `+` is added.*

**Check yourself:** can you explain, out loud, the difference between `add`,
`commit`, and `push` — and why a commit is still "yours" before you push? And the
difference between `reset` (rewrites history, local only) and `revert` (safe for
pushed/shared work)?
