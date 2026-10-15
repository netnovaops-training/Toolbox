# Daily log — quick end-of-day capture

> **what:** a few lines each day on what I did, so progress is never lost
> **status:** useful
> **tags:** daily, progress, log
> **last-used:** 2026-10-15

Where my notes land day to day. Keep each one **short** — a few bullets. These feed
two things:
- the **short issues → resolutions** table in [../troubleshooting/README.md](../troubleshooting/README.md)
  (when I solved something worth a full write-up), and
- the **Recent progress** list in [../../PORTFOLIO.md](../../PORTFOLIO.md) (one highlight line).

## Do this at the end of a day
1. Make today's file (fills the date for you):
   ```
   cp knowledge/daily-log/_daily-template.md "knowledge/daily-log/$(date +%F).md"
   ```
2. Jot a few bullets (what I did, what I learned, any issue→fix).
3. If I solved a real problem: also copy the troubleshooting `_template.md` into a
   full entry and add a row to that table.
4. Add one highlight line to `PORTFOLIO.md` under "Recent progress."
5. `git add` → `commit -m "Daily log: <date>"` → `push`.

Keep it generic and public-safe — no secrets, no real IPs/homelab details.
