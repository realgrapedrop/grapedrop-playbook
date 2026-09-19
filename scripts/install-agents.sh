#!/usr/bin/env bash
# Agents install helper for the playbook.
# Copies persona-backed agent definitions from .project/playbook/reference/agents/
# into .claude/agents/ so Claude Code's native /agents command sees the
# project team.
#
# Run from your project root:
#
#   bash .project/playbook/scripts/install-agents.sh
#
# Optional: pass one or more agent names to install only those.
#
#   bash .project/playbook/scripts/install-agents.sh architect developer
#
# Safe to re-run. Existing .claude/agents/<name>.md files are overwritten
# with the latest from .project/playbook/reference/agents/. Safe in a repo
# that already has its own agents: on a first install (no version stamp yet),
# a file of yours that shares a name with a playbook agent is copied to
# .claude/playbook-backup/agents/ before it is replaced. The script also
# installs the security baseline at .claude/SECURITY-POSTURE.md (copied from
# .project/playbook/reference/rules/SECURITY-POSTURE.md) on first run only;
# existing project customizations are preserved on re-run. It also stamps the
# installed playbook version to .claude/playbook-version so a later
# verify-install.sh run can tell whether the install is current. The script
# prints what changed and verifies the install before exiting.

set -euo pipefail

# Colors (auto-disabled when not a TTY)
if [ -t 1 ]; then
  C_RED='\033[0;31m'
  C_GRN='\033[0;32m'
  C_YEL='\033[1;33m'
  C_BLU='\033[0;34m'
  C_OFF='\033[0m'
else
  C_RED=''
  C_GRN=''
  C_YEL=''
  C_BLU=''
  C_OFF=''
fi

info() { printf "${C_BLU}[INFO]${C_OFF} %s\n" "$1"; }
ok()   { printf "${C_GRN}[ OK ]${C_OFF} %s\n" "$1"; }
warn() { printf "${C_YEL}[WARN]${C_OFF} %s\n" "$1"; }
err()  { printf "${C_RED}[ERR ]${C_OFF} %s\n" "$1"; }

SRC=".project/playbook/reference/agents"
DST=".claude/agents"

usage() {
  cat <<EOF

Usage: bash .project/playbook/scripts/install-agents.sh [<agent> ...]

Installs persona-backed agent definitions from $SRC into $DST.

With no arguments, all 17 agents are installed:

  architect, brand, bizdev, community, compliance, customer-success, designer,
  developer, enduser, finance, legal, marketing, people, qa-engineer, sales,
  security-auditor, support

Pass one or more agent names to install only those.

Examples:
  bash .project/playbook/scripts/install-agents.sh
  bash .project/playbook/scripts/install-agents.sh architect developer
  bash .project/playbook/scripts/install-agents.sh legal compliance finance
EOF
}

case "${1:-}" in
  -h|--help|help)
    usage
    exit 0
    ;;
esac

# ---------- Pre-flight ----------
echo
info "Pre-flight: verify source agent definitions exist."
if [ ! -d "$SRC" ]; then
  err "Source folder $SRC not found. Make sure the playbook is at .project/playbook/."
  exit 1
fi

AGENT_COUNT=$(find "$SRC" -maxdepth 1 -name '*.md' -type f -not -name 'README.md' | wc -l)
if [ "$AGENT_COUNT" -eq 0 ]; then
  err "No agent definitions found in $SRC."
  exit 1
fi
ok "$AGENT_COUNT agent definition(s) available in $SRC."

# ---------- Pre-flight: Claude Code ----------
echo
info "Pre-flight: verify Claude Code is installed."
if ! command -v claude >/dev/null 2>&1; then
  err "Claude Code not found on PATH. Run install-core.sh first."
  exit 1
fi
ok "Claude Code present: $(claude --version 2>/dev/null || echo 'version unknown')"

# ---------- Ensure destination exists ----------
echo
info "Ensure $DST exists."
mkdir -p "$DST"
ok "Destination ready: $DST"

# ---------- Determine which agents to install ----------
if [ $# -gt 0 ]; then
  AGENTS=("$@")
  info "Installing requested agents: ${AGENTS[*]}"
else
  # Install all (excluding the folder's own README.md)
  AGENTS=()
  for f in "$SRC"/*.md; do
    name="$(basename "$f" .md)"
    [ "$name" = "README" ] && continue
    AGENTS+=("$name")
  done
  info "Installing all available agents: ${AGENTS[*]}"
fi

# ---------- Copy each agent ----------
# On a first install there is no version stamp yet, so an agent file already
# sitting at the target was written by the project, not by this playbook (an
# existing repo may well have its own developer.md). Back it up before copying.
# Once the stamp exists, overwriting is the documented refresh and no backup is
# taken. Backups live outside .claude/agents/ on purpose: Claude Code would load
# a stray .md in that directory as a live agent.
FIRST_INSTALL=0
[ -f ".claude/playbook-version" ] || FIRST_INSTALL=1
BACKUP_DIR=".claude/playbook-backup/agents"
INSTALLED=0
FAILED=0
BACKED_UP=0
for agent in "${AGENTS[@]}"; do
  src_file="$SRC/$agent.md"
  dst_file="$DST/$agent.md"
  if [ ! -f "$src_file" ]; then
    err "No source for agent '$agent' at $src_file"
    FAILED=$((FAILED + 1))
    continue
  fi
  if [ "$FIRST_INSTALL" -eq 1 ] && [ -f "$dst_file" ] && ! cmp -s "$src_file" "$dst_file"; then
    mkdir -p "$BACKUP_DIR"
    if [ -e "$BACKUP_DIR/$agent.md" ]; then
      err "Your own $dst_file would be overwritten, and a backup already exists at $BACKUP_DIR/$agent.md."
      err "Move one of them out of the way, then re-run. Skipping '$agent'."
      FAILED=$((FAILED + 1))
      continue
    fi
    if cp "$dst_file" "$BACKUP_DIR/$agent.md"; then
      warn "You already had an agent named '$agent'. Your copy is saved at $BACKUP_DIR/$agent.md."
      BACKED_UP=$((BACKED_UP + 1))
    else
      err "Could not back up your existing $dst_file. Skipping '$agent' so nothing is lost."
      FAILED=$((FAILED + 1))
      continue
    fi
  fi
  if cp "$src_file" "$dst_file"; then
    ok "Installed: $agent  ($dst_file)"
    INSTALLED=$((INSTALLED + 1))
  else
    err "Failed to copy $src_file to $dst_file"
    FAILED=$((FAILED + 1))
  fi
done

# ---------- Security baseline ----------
echo
info "Install security baseline."
SEC_SRC=".project/playbook/reference/rules/SECURITY-POSTURE.md"
SEC_DST=".claude/SECURITY-POSTURE.md"
if [ ! -f "$SEC_SRC" ]; then
  warn "Source $SEC_SRC not found. Security baseline not installed."
elif [ -f "$SEC_DST" ]; then
  ok "Existing $SEC_DST preserved (project customizations not overwritten)."
else
  if cp "$SEC_SRC" "$SEC_DST"; then
    ok "Installed: security baseline ($SEC_DST)"
  else
    err "Failed to copy $SEC_SRC to $SEC_DST"
    FAILED=$((FAILED + 1))
  fi
fi

# ---------- Version stamp ----------
echo
info "Stamp the installed playbook version."
VER_SRC=".project/playbook/VERSION"
VER_DST=".claude/playbook-version"
if [ ! -f "$VER_SRC" ]; then
  warn "No $VER_SRC found. Version not stamped (older playbook clone; pull the latest)."
else
  if cp "$VER_SRC" "$VER_DST"; then
    ok "Stamped: $(head -n1 "$VER_DST") ($VER_DST)"
  else
    err "Failed to write $VER_DST"
    FAILED=$((FAILED + 1))
  fi
fi

# ---------- Done ----------
echo
ok "Agents install summary. Installed: $INSTALLED. Failed: $FAILED."
if [ "$BACKED_UP" -gt 0 ]; then
  warn "$BACKED_UP agent(s) you already had shared a name with a playbook agent. The playbook"
  warn "version is now installed and yours are saved in $BACKUP_DIR/. To keep yours, rename it"
  warn "(file name and the name: line) and move it back into $DST/."
fi

if [ "$FAILED" -gt 0 ]; then
  exit 1
fi

echo
info "Next steps."
echo "  0. Verify the whole install end to end (agents, security baseline, version stamp):"
echo
echo "       bash .project/playbook/scripts/verify-install.sh"
echo
echo "  1. Nothing to reload. Claude Code watches .claude/agents/ and picks up the new"
echo "     definitions within seconds. Restart only if .claude/agents/ did not exist when"
echo "     your session started."
echo "  2. To see the team, run 'ls .claude/agents/' or ask Claude. The /agents wizard was"
echo "     removed in Claude Code v2.1.198; agents that are running show up in /tasks."
echo "  3. Invoke an agent on a task. Example prompt at the Claude Code prompt:"
echo
echo "       Using the architect agent, draft the principles section of docs/DESIGN.md"
echo "       based on the spec at docs/specs/YYYY-MM-DD-<topic>-design.md."
echo
echo "  4. Each agent has memory: project frontmatter, so Claude Code creates"
echo "     .claude/agent-memory/<agent-name>/MEMORY.md automatically on first use."
echo "     That file is the agent's cross-session recall; the agent reads and updates"
echo "     it without any prompt from you."
echo
echo "  5. Shared project knowledge lives at .project/playbook/knowledge/<topic>.md."
echo "     Read the knowledge/README.md for the convention. Agents are instructed to"
echo "     write project-level discoveries there so every other agent sees them."
echo
