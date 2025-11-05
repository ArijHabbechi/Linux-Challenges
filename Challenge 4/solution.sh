#!/bin/bash
# =============================================================================
# APPDATA WORKFLOW: CREATE • FIND • REPLACE • ARCHIVE • PERMISSIONS • SOFTLINK • SCRIPT
# =============================================================================

set -euo pipefail

# ---------- Helper functions ----------
banner() {
  echo
  echo "========== $* =========="
  echo
}

step() {
  echo "→ $*"
}

ok() {
  echo "✓ $*"
}

warn() {
  echo "! $*"
}

# ---------- Sudo helper ----------
if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
  SUDO="sudo"
else
  SUDO=""
fi

# ============================================================================ #
# 0) CREATE: /opt/appdata directory
# ============================================================================ #
banner "CREATE"
step "0) Ensure /opt/appdata exists"
$SUDO mkdir -p /opt/appdata
ok "/opt/appdata is ready"

# ============================================================================ #
# FIND
# ============================================================================ #
banner "FIND"

# 1) Hidden files
step "1) Copy HIDDEN files from /home/bob/preserved → /opt/appdata/hidden/"
$SUDO mkdir -p /opt/appdata/hidden
$SUDO find /home/bob/preserved -type f -name ".*" -exec cp {} /opt/appdata/hidden/ \;
ok "Hidden files copied (if any)"

# 2) Non-hidden files
step "2) Copy NON-HIDDEN files from /home/bob/preserved → /opt/appdata/files/"
$SUDO mkdir -p /opt/appdata/files
$SUDO find /home/bob/preserved -type f ! -name ".*" -exec cp {} /opt/appdata/files/ \;
ok "Non-hidden files copied (if any)"

# 3) Find & delete files in /opt/appdata containing a word ending with 't' (case-sensitive)
step "3) Delete files in /opt/appdata whose CONTENT contains a word ending with 't' (case-sensitive)"
$SUDO find /opt/appdata -type f -exec grep -l 't\>' {} \; -exec rm -f {} \; || true
ok "Matching files deleted (if any)"

# ============================================================================ #
# REPLACE
# ============================================================================ #
banner "REPLACE"

# 1) yes → no
step "1) Replace all whole-word 'yes' with 'no' under /opt/appdata (recursive)"
$SUDO find /opt/appdata -type f -exec sed -i 's/\byes\b/no/g' {} \;
ok "Replacements complete (yes → no)"

# 2) raw → processed
step "2) Replace all whole-word 'raw' (any case) with 'processed' under /opt/appdata"
$SUDO find /opt/appdata -type f -exec sed -i 's/\b[Rr][Aa][Ww]\b/processed/g' {} \;
ok "Replacements complete (raw → processed, case-insensitive)"

# ============================================================================ #
# ARCHIVE
# ============================================================================ #
banner "ARCHIVE"
step "Create /opt/appdata.tar.gz from /opt/appdata"
$SUDO tar -czf /opt/appdata.tar.gz -C /opt appdata
ok "Archive created at /opt/appdata.tar.gz"

# ============================================================================ #
# PERMISSIONS
# ============================================================================ #
banner "PERMISSIONS"

# 1) Sticky bit on dir
step "1) Add sticky bit on /opt/appdata (keep other perms)"
$SUDO chmod +t /opt/appdata
ok "Sticky bit set"

# 2) Ownership of archive
step "2) Make 'bob' the user and group owner of /opt/appdata.tar.gz"
$SUDO chown bob:bob /opt/appdata.tar.gz
ok "Owner/group set to bob:bob"

# 3) Mode 440
step "3) Set read-only for user/group (440), no perms for others on /opt/appdata.tar.gz"
$SUDO chmod 440 /opt/appdata.tar.gz
ok "Permissions set to 440"

# ============================================================================ #
# SOFTLINK
# ============================================================================ #
banner "SOFTLINK"
step "Create symlink /home/bob/appdata.tar.gz → /opt/appdata.tar.gz"
$SUDO ln -sf /opt/appdata.tar.gz /home/bob/appdata.tar.gz
ok "Symlink created"

# ============================================================================ #
# SCRIPT
# ============================================================================ #
banner "SCRIPT"

# 1) Create /home/bob/filter.sh
step "1) Write /home/bob/filter.sh"
$SUDO tee /home/bob/filter.sh >/dev/null <<'SH'
#!/bin/bash
set -euo pipefail
# Filter lines containing "processed" from the CONTENTS of /opt/appdata.tar.gz
# Overwrite /home/bob/filtered.txt each run
tar -xOzf /opt/appdata.tar.gz | grep -a "processed" > /home/bob/filtered.txt
SH
ok "Script created"

# 2) Make it executable
step "2) chmod +x /home/bob/filter.sh"
$SUDO chmod +x /home/bob/filter.sh
ok "Executable bit set"

# 3) Run it
step "3) Run /home/bob/filter.sh"
$SUDO /home/bob/filter.sh || warn "Script ran but may have produced no matches"

# 4) Show filtered output
step "4) Show /home/bob/filtered.txt (if exists)"
if $SUDO test -f /home/bob/filtered.txt; then
  $SUDO cat /home/bob/filtered.txt || true
  ok "Displayed /home/bob/filtered.txt"
else
  warn "/home/bob/filtered.txt not found"
fi

echo
echo "ALL DONE! 🎉"
