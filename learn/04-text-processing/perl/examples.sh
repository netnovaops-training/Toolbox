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

echo "Done. Scratch dir removed on exit."
