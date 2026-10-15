#!/usr/bin/env bash
# One-liners adapted from trimstray/the-book-of-secret-knowledge (MIT).
#
# perl one-liners: fast search/replace and line editing from the shell.
# Some lines CHANGE files (marked WARNING). Everything runs in a scratch dir;
# still, practice in a throwaway VM to build the habit.

# Safety flags (see terminal/examples.sh). Left off so the demo keeps flowing.
# set -euo pipefail

SCRATCH="$(mktemp -d)"
trap 'rm -rf "$SCRATCH"' EXIT
cd "$SCRATCH"

# perl is on nearly every Linux box, but check so the script explains itself.
if ! command -v perl >/dev/null 2>&1 ; then
  echo "perl is not installed here. On Debian/Ubuntu: sudo apt install perl"
  echo "Read the comments below to learn what each command would do."
fi

# Sample files.
cat > app.conf << '__EOF__'
foo = 1
foobar = keep-me
service foo enabled
tab	separated	values
__EOF__

printf 'l1\nl2\nl3\nl4\nl5\nl6\nl7\nl8\nl9\nl10\nl11\nl12\n' > lines.txt

# --- Preview a search/replace (no -i, so nothing is written) ---------------
# -p loops over each line and auto-prints it after running the code.
# \bfoo\b uses word boundaries so 'foobar' is NOT touched, only the word 'foo'.
echo "== preview: whole-word foo -> bar (file unchanged) =="
perl -pe 's/\bfoo\b/bar/g' app.conf

# --- Search/replace in place, with a backup --------------------------------
# WARNING: -i edits the file. -i.orig writes app.conf.orig first so you can undo.
echo "== editing in place (backup -> app.conf.orig) =="
perl -i.orig -pe 's/\bfoo\b/bar/g' app.conf
cat app.conf
echo "-- backup keeps the original:"; cat app.conf.orig

# --- Print the first N lines -----------------------------------------------
# $. is the line number. exit once we pass line 3. -p still prints lines 1..3.
echo "== first 3 lines of lines.txt =="
perl -pe 'exit if $. > 3' lines.txt

# --- Print a range of lines ------------------------------------------------
# -n is silent; we print only when the range operator is true (lines 4..6).
echo "== lines 4 through 6 =="
perl -ne 'print if 4 .. 6' lines.txt

# --- Delete the first N lines (keep the rest) ------------------------------
# WARNING: -i edits the file. 'unless 1 .. 5' prints every line EXCEPT 1..5.
cp lines.txt cut.txt
echo "== drop the first 5 lines of cut.txt =="
perl -i.orig -ne 'print unless 1 .. 5' cut.txt
cat cut.txt

# --- Keep everything EXCEPT the block between two markers ------------------
# WARNING: -i edits the file. The range runs from a line matching ^start$ to one
# matching ^end$; 'unless' drops that block (markers included).
cat > block.txt << '__EOF__'
header
start
secret line a
secret line b
end
footer
__EOF__
echo "== remove the start..end block =="
perl -i.orig -ne 'print unless /^start$/ .. /^end$/' block.txt
cat block.txt

# --- Convert tabs to two spaces --------------------------------------------
# WARNING: -i edits the file. s/\t/  /g replaces every tab with two spaces.
cp app.conf tabs.txt
echo "== tabs -> 2 spaces =="
perl -i -pe 's/\t/  /g' tabs.txt
cat tabs.txt

# --- Count lines and characters --------------------------------------------
# -l handles newlines; we tally in $i and $in, then report once in END.
echo "== line and character count of lines.txt =="
perl -lne '$i++; $in += length($_); END { print "$i lines, $in characters"; }' lines.txt

# An access log for the harder, job-shaped examples.
cat > access.log << '__EOF__'
10.0.0.1 - - [15/Oct/2026:08:01] "GET /home" 200 531
10.0.0.2 - - [15/Oct/2026:08:05] "GET /app?id=7" 200 1200
10.0.0.1 - - [15/Oct/2026:09:02] "POST /login" 401 90
10.0.0.3 - - [15/Oct/2026:09:33] "GET /app?id=9" 500 0
10.0.0.1 - - [15/Oct/2026:09:47] "GET /home" 200 531
__EOF__

# --- HARDER: swap key and value with capture groups ------------------------
# ( ) capture; $1 and $2 reuse them in the replacement. -p previews each line.
echo "== swap key=value into value=key (preview) =="
printf 'host=web1\nport=8080\nrole=db\n' > kv.txt
perl -pe 's/(\w+)=(\w+)/$2=$1/' kv.txt

# --- HARDER: extract a captured field only ---------------------------------
# -n is silent; we print just the capture when the line matches. The (?:...) is
# a NON-capturing group so $1 is the path, not the method.
echo "== requested paths only =="
perl -ne 'print "$1\n" if /"(?:GET|POST) (\S+)"/' access.log

# --- HARDER + COMBINE: top requested paths (perl | sort | uniq -c | sort) --
# perl extracts the path; the standard ranking pipeline counts and orders them.
echo "== top requested paths =="
perl -ne 'print "$1\n" if /"(?:GET|POST) (\S+)"/' access.log \
  | sort | uniq -c | sort -nr

# --- HARDER: autosplit into @F (awk-style fields) --------------------------
# -a splits each line into @F on whitespace. $F[0] is first field, $F[-1] last.
echo "== first and last field of each request line =="
perl -lane 'print "$F[0] -> $F[-1]"' access.log

# --- HARDER: whole-file (slurp) edit across newlines -----------------------
# -0777 reads the ENTIRE file into $_ so the regex can span lines. /s lets . match
# newlines; .*? is non-greedy so we remove each block, not everything between the
# first and last marker. No -i here: we write to a NEW file and keep the original.
echo "== remove an HTML comment block that spans lines =="
cat > page.html << '__EOF__'
<h1>Title</h1>
<!-- TODO: remove
this secret note
before launch -->
<p>Body</p>
__EOF__
perl -0777 -pe 's/<!--.*?-->//gs' page.html > page.clean.html
echo "-- cleaned file:"; cat page.clean.html

# --- HARDER + COMBINE: preview THEN apply a multi-file replace -------------
# WARNING: the apply step (-i) changes files. Safe pattern: preview across every
# file find selected, read it, and only then re-run with -i.orig for backups.
echo "== multi-file replace: preview first =="
cp kv.txt a.txt; cp kv.txt b.txt
# $ARGV is the current filename, so the preview shows which file each hit is in.
find . -maxdepth 1 -name '?.txt' -print0 | xargs -0 perl -ne 'print "$ARGV: $_" if /8080/'
echo "-- now applying with a .orig backup on each file --"
# Apply (safe: scratch dir). -i.orig keeps a backup of every file touched.
find . -maxdepth 1 -name '?.txt' -print0 | xargs -0 perl -i.orig -pe 's/8080/9090/g'
grep port a.txt b.txt

echo "Done. Scratch dir removed on exit."
