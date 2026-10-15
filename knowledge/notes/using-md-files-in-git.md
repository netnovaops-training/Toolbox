# Using .md files in git (how I write and keep my notes)

> **what:** how markdown files work in a git repo, and how I use them
> **status:** useful
> **tags:** markdown, git, docs, notes
> **last-used:** 2026-10-15

A `.md` file is just a text file with light formatting. In a git repo it's the
normal way to keep notes, guides, and READMEs, because GitHub renders it nicely and
git tracks every change.

## Markdown basics (all I usually need)

```
# Big heading        ## Smaller       ### Smaller still
**bold**   *italic*   `inline code`
- bullet list        1. numbered list
- [ ] to-do (unchecked)   - [x] done
[link text](https://example.com)
> quote / callout
```
Code block (keeps formatting, good for commands):
<pre>
```
ip a
ping -c 4 example.com
```
</pre>
Table:
```
| col | col |
|-----|-----|
| a   | b   |
```

## README.md is special
A folder's `README.md` is shown automatically as that folder's front page on GitHub.
So the top-level README is the repo's home page; each folder's README introduces it.

## How I use .md files here
- **Notes/guides** → `knowledge/notes/*.md`
- **Cheat sheets** → `knowledge/cheatsheets/*.md`
- **Lesson docs** → `learn/.../doc.md`
- Every file starts with the header block (what / status / tags / last-used).

## The git loop for a note (same as any file)
```
# make or edit the .md in the right folder, then:
git add knowledge/notes/my-note.md
git commit -m "Add note on X"
git push
```
Edit it later, commit again — git keeps every version, so I can see how a note grew
or go back if I mess it up.

## Tips
- Preview before committing: GitHub's web/app renders it; VS Code has a preview pane.
- Keep lines readable; blank line between paragraphs.
- Checkboxes (`- [ ]`) are great for a to-do or a checklist I tick off over time.
