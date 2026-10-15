# TODO

My learning to-dos. Tick a box when done.

- [ ] **Practice the git branch → PR → merge flow** (ask mentor to walk Part B/C). #git #career
  Part A — in Termux:
  1. `git switch main && git pull`
  2. `git switch -c feature/my-first-pr`
  3. `mkdir -p sandbox && echo "My first PR - $(date +%F)" > sandbox/first-pr.md`
  4. `git add sandbox/first-pr.md && git commit -m "Practice: add first-pr note"`
  5. `git push -u origin feature/my-first-pr`  (prints a PR link)
  Part B — on GitHub: open the PR (feature → main), review, Merge, delete the branch.
  Part C — back in Termux: `git switch main && git pull` (and delete the local branch).
- [ ] **Try `newfix.sh`** (haven't run it yet) — tomorrow. #git #toolbox
  `bash code/local/newfix.sh short-title`  (note the slash: code/local/ ... )
  Then open the new file, fill the XXX, and: `git add knowledge/troubleshooting/ && git commit -m "Troubleshooting: short-title" && git push`
