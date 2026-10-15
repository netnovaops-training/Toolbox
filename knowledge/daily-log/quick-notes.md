# Quick notes

> **what:** fast one-line notes and small changes, tagged in the moment
> **status:** useful
> **tags:** notes, log, tags
> **last-used:** 2026-10-15

One line per note. Newest at the bottom. Format:

```
YYYY-MM-DD — what I did or changed  #tag #tag
```

**Tags** are just `#word` typed in the line. They show as text and are **searchable**
on GitHub (search box → type `#networking` to pull up every note with it).

Click any tag in [TAGS.md](../../TAGS.md) to see every note that uses it (live search).

Common tags to reuse (pick any, make new ones freely):
`#networking` `#linux` `#docker` `#security` `#scripting` `#git` `#dns` `#caddy`
Project tags: `#homelab` `#junsgarden` `#toolbox` `#career` `#certs`

## Fastest way to add one (terminal)
```
echo "$(date +%F) — did a thing  #tag" >> knowledge/daily-log/quick-notes.md
git commit -am "note" && git push
```
(That appends today's date + your note, then cements it in one go.)

---

## Notes
- 2026-10-15 — set up quick-notes with in-line #tags  #toolbox #notes
2026-10-15 - test scripts #debug #script
2026-10-15 - Fixed install script cross-platform move/rename logic by using absolute paths #debug #bash #resolved
