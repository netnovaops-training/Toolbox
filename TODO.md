# TODO

My learning to-dos. Tick a box when done.

- [ ] **Merge my first real pull request: the logbook system (PR #2).** #git #career
  1. Open https://github.com/netnovaops-training/Toolbox/pull/2
  2. Read "Files changed", check the green ticks, then **Merge pull request**.
  3. Watch the Actions tab: the `logbook` run rebuilds LOGBOOK.md and JACKET.md on main.
  4. Back in Termux: `git switch main && git pull`.

- [ ] **Open my first ticket: "add branches to my flow"** (the first project entry). #git #toolbox
  1. `git switch main && git pull`
  2. `bash code/local/newentry.sh project add-branches-to-flow git github`
     (it makes the branch, the entry, pushes, and prints a link - open a **draft** PR there)
  3. Fill in the XXX parts as I go. Save each session with
     `bash code/local/worklog.sh "what I did"`
  4. When done: `bash code/local/resolve.sh`, mark the PR **Ready for review**, then **Merge**.

- [ ] **Try a quick fix ticket** the next time something small breaks. #toolbox
  `bash code/local/newentry.sh quick short-title <tech>`
