---
type: project
title: portfolio redesign
date: 2026-10-15
branch: project/portfolio-redesign
tech: [markdown, github]
status: in-progress
opened: 2026-10-15
closed:
tags: [portfolio, career]
summary: Rewrote PORTFOLIO.md from a long list of lessons into a short page that leads with projects across all my repos.
lesson: A portfolio should show what I built and what it did in a few lines, and link to the detail instead of repeating it.
---

# portfolio redesign

<!-- Project report. Fill in every placeholder. No secrets, keys, real IPs, or homelab details.
     Save progress:  bash code/local/worklog.sh "what I did"
     Close it:       bash code/local/resolve.sh -->

## Goal
- **What I'm building and why:** the old portfolio was 68 lines, listed lessons instead of results, and only covered this repo. It was too much to show someone.
- **Done looks like:** one short page someone can read in a minute: who I am, my projects across repos, and where to find proof.

## Environment
- Markdown on GitHub; read on phone and desktop

## Steps
1. Read the old page and listed what a reader actually needs: role goal, projects, proof.
2. Led with projects across repos: Jun's Garden, Toolbox, learning-lab.
3. Wrote each project as a one-line description plus a few results, with the tools as tags.
4. Moved the detail out: lessons go to JACKET.md, write-ups to LOGBOOK.md; the skills table keeps one or two proof links each.
5. Dropped the hand-kept "recent progress" list - the logbook timeline does that automatically now.

## Issues hit
- Jun's Garden, my biggest project, wasn't on the page at all -> added it first, described from its README so the facts are accurate.

## Result (verified)
- **What works now:** the page is about half the length, starts with projects, and every link goes to real work.
- **How I confirmed it:** previewed it on the pull request on my phone and checked each link opens.

## What I learned
- Lead with results, not a list of everything I touched.
- Link to detail instead of copying it, so the page stays short and doesn't go stale.

## Work log
- 2026-10-15 - opened
- 2026-10-15 - rewrote PORTFOLIO.md around projects across repos
