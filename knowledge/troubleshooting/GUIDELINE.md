# What a good troubleshooting entry looks like (depth guide)

> **what:** the quality bar for a troubleshooting write-up
> **status:** useful
> **tags:** troubleshooting, writing, quality
> **last-used:** 2026-10-15

The goal: anyone (including future me, or an interviewer) can read it and see **that
I can diagnose and fix a real problem**. Specific beats vague. Reasoning beats a bare
answer. Keep it generic (no secrets/real IPs).

## Section by section — what to put, and how deep

**Title / what** — name the actual symptom, not "it broke."
- shallow: "Docker issue"
- good: "Container couldn't write to its mounted volume (permission denied)"

**One-line (interview version)** — problem → what I did → result, in one sentence.
- "A container couldn't write its volume — I matched its UID to the host folder's owner and the app came back up."

**The problem** — 1–2 sentences: what broke, when, and the impact (what couldn't happen because of it). Context matters: what were you doing?

**Symptoms** — the *evidence*. The exact error line (if short and secret-free), the behaviour, where you saw it (logs? a command's output?). This is what you'd actually grep for later.

**What I tried** — the heart of it. List your steps **in order, including the ones that failed**, and why you moved on. This shows how you *think*, which is what interviewers score. Aim for 3+ steps.
- shallow: "I fixed the permissions."
- good: "Confirmed I could write the folder myself (I could) → chmod 777 'worked' but is unsafe, so I kept digging → compared the container's UID to the folder's owner."

**The cause** — the *root* cause in plain words, not just the fix. "Why did it happen?" (e.g., "the container ran as UID 0 but the host folder was owned by UID 1000").

**The fix** — the exact, reproducible steps/commands that solved it, generic (no secrets). If there were two valid fixes, note both and why you chose one.

**What I learned / how I'm more prepared** — the takeaway in one line, plus the **first thing you'll check next time** so it's faster or never happens again. This is the part employers care about most — it shows you grow.

## The quality checklist
- [ ] Specific symptom in the title (not "error" / "issue")
- [ ] The one-liner reads as problem → action → result
- [ ] "What I tried" shows real reasoning, including a dead end
- [ ] Root **cause** named, separate from the fix
- [ ] Fix is **reproducible** and generic (no secrets/real IPs/homelab)
- [ ] "What I learned" + "check this first next time" is filled in

## How deep? A rule of thumb
5–15 minutes to write. Long enough that someone could **reproduce the fix and
understand the cause**; short enough that you'll actually do it every time. Depth is
in the *reasoning* (What I tried / Cause / Learned), not in word count.

Small fix with little to say? Use `_quick.md` (Issue / Fix / Learned). Worth the full
story? Use `_template.md` and hit the checklist above.
