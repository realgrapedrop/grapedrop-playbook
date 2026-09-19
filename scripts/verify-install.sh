#!/usr/bin/env bash
# Post-install health check for the playbook.
# Verifies that the pieces the install scripts and the bootstrap wizard put in
# place are actually there and consistent: the 17 agents, the security baseline
# (including drift against the playbook reference copy), the version stamp, the
# universal core, the memory surfaces, and the context baseline.
#
# Run from your project root:
#
#   bash .project/playbook/scripts/verify-install.sh
#
# Read-only. This script never writes or changes anything; it only reports.
# Exit code 0 when nothing is broken. Exit code 1 when something the install
# scripts should have produced is missing. Warnings (customized files, optional
# pieces not installed) do not fail the check.

set -uo pipefail

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

ERRORS=0
WARNINGS=0
info() { printf "${C_BLU}[INFO]${C_OFF} %s\n" "$1"; }
ok()   { printf "${C_GRN}[ OK ]${C_OFF} %s\n" "$1"; }
warn() { printf "${C_YEL}[WARN]${C_OFF} %s\n" "$1"; WARNINGS=$((WARNINGS + 1)); }
err()  { printf "${C_RED}[ERR ]${C_OFF} %s\n" "$1"; ERRORS=$((ERRORS + 1)); }

PLAYBOOK=".project/playbook"

# ---------- Check 1. Playbook clone ----------
echo
info "Check 1. Playbook is present."
if [ ! -d "$PLAYBOOK/reference/agents" ]; then
  err "No playbook found at $PLAYBOOK/. Run this script from your project root."
  echo
  err "Verification failed: 1 error. Nothing else can be checked."
  exit 1
fi
ok "Playbook found at $PLAYBOOK/."

# ---------- Check 2. Version stamp ----------
echo
info "Check 2. Version stamp matches the playbook version."
REF_VERSION_FILE="$PLAYBOOK/VERSION"
STAMP_FILE=".claude/playbook-version"
if [ ! -f "$REF_VERSION_FILE" ]; then
  warn "No $REF_VERSION_FILE in the playbook clone. This playbook predates version stamping; pull the latest."
elif [ ! -f "$STAMP_FILE" ]; then
  warn "No version stamp at $STAMP_FILE. Re-run install-agents.sh to stamp the installed version."
else
  REF_VERSION="$(head -n1 "$REF_VERSION_FILE" | tr -d '[:space:]')"
  STAMPED="$(head -n1 "$STAMP_FILE" | tr -d '[:space:]')"
  if [ "$REF_VERSION" = "$STAMPED" ]; then
    ok "Installed version $STAMPED matches the playbook clone."
  else
    warn "Installed version is $STAMPED but the playbook clone is $REF_VERSION."
    info "Your install came from an older playbook. Read $PLAYBOOK/CHANGELOG.md for what changed"
    info "between $STAMPED and $REF_VERSION, then re-run the installers (see docs/USER-GUIDE.md,"
    info "Updating the playbook)."
  fi
fi

# ---------- Check 3. Agents ----------
echo
info "Check 3. Every shipped agent is installed."
AGENT_SRC="$PLAYBOOK/reference/agents"
AGENT_DST=".claude/agents"
MISSING=0
DRIFTED=0
PRESENT=0
if [ ! -d "$AGENT_DST" ]; then
  err "No $AGENT_DST directory. Run: bash $PLAYBOOK/scripts/install-agents.sh"
else
  for src_file in "$AGENT_SRC"/*.md; do
    name="$(basename "$src_file" .md)"
    [ "$name" = "README" ] && continue
    dst_file="$AGENT_DST/$name.md"
    if [ ! -f "$dst_file" ]; then
      err "Agent '$name' not installed (missing $dst_file)."
      MISSING=$((MISSING + 1))
    elif ! cmp -s "$src_file" "$dst_file"; then
      warn "Agent '$name' differs from the playbook reference (edited locally, or from an older playbook)."
      DRIFTED=$((DRIFTED + 1))
    else
      PRESENT=$((PRESENT + 1))
    fi
  done
  if [ "$MISSING" -eq 0 ]; then
    ok "All shipped agents installed ($PRESENT current, $DRIFTED differing from reference)."
    if [ "$DRIFTED" -gt 0 ]; then
      info "A differing agent is fine if you edited it on purpose. If not, refresh with:"
      info "  bash $PLAYBOOK/scripts/install-agents.sh"
    fi
  fi
fi

# ---------- Check 4. Security baseline ----------
echo
info "Check 4. Security baseline installed, and drift against the reference copy."
SEC_REF="$PLAYBOOK/reference/rules/SECURITY-POSTURE.md"
SEC_PROD=".claude/SECURITY-POSTURE.md"
if [ ! -f "$SEC_PROD" ]; then
  err "No security baseline at $SEC_PROD. Run: bash $PLAYBOOK/scripts/install-agents.sh"
elif [ ! -f "$SEC_REF" ]; then
  warn "Playbook reference copy missing at $SEC_REF. The clone may be damaged; re-pull it."
elif cmp -s "$SEC_REF" "$SEC_PROD"; then
  ok "The two security-baseline copies are in sync."
else
  warn "The production copy $SEC_PROD differs from the playbook reference $SEC_REF."
  info "That is expected if you customized the production copy, and it stays the source of"
  info "truth. If the difference is a surprise, inspect it before changing anything:"
  info "  diff $SEC_REF $SEC_PROD"
fi

# ---------- Check 5. Universal core ----------
echo
info "Check 5. Universal core tools (missing pieces are warnings, not failures)."
if command -v claude >/dev/null 2>&1; then
  ok "Claude Code present: $(claude --version 2>/dev/null || echo 'version unknown')"
else
  warn "Claude Code not on PATH. Codex-only setups are fine; otherwise run install-core.sh."
fi
if [ -d "$HOME/.claude/plugins/cache/claude-plugins-official/superpowers" ]; then
  ok "superpowers plugin present."
else
  warn "superpowers plugin not found (install-core.sh Step 2)."
fi
if [ -d "$HOME/.claude/plugins/cache/parallel-agent-skills/parallel" ]; then
  ok "parallel-agent-skills plugin present."
else
  warn "parallel-agent-skills plugin not found (install-core.sh Step 6; Claude Code only)."
fi
if command -v parallel-cli >/dev/null 2>&1; then
  ok "parallel-cli present: $(parallel-cli --version 2>/dev/null || echo 'version unknown')"
else
  warn "parallel-cli not on PATH (install-core.sh Step 3)."
fi
if [ -d "$HOME/.agents/skills/loop-engineering" ]; then
  ok "loop-engineering skill present."
else
  warn "loop-engineering skill not found (install-core.sh Step 7; needs Node 20+)."
fi

# ---------- Check 6. Memory and knowledge surfaces ----------
echo
info "Check 6. Memory and knowledge surfaces."
if [ -d ".claude/agent-memory" ]; then
  ok "Per-agent memory directory exists (.claude/agent-memory/)."
  # The auto-inject budget: Claude Code injects the first 200 lines or 25KB of an
  # agent's MEMORY.md. Anything past that silently never reaches the agent.
  while IFS= read -r mem_file; do
    lines="$(wc -l < "$mem_file")"
    bytes="$(wc -c < "$mem_file")"
    if [ "$lines" -gt 200 ] || [ "$bytes" -gt 25600 ]; then
      warn "$mem_file is $lines lines / $bytes bytes; past 200 lines or 25KB the rest is"
      warn "silently not injected. Compact it per $PLAYBOOK/reference/rules/MEMORY-HYGIENE.md."
    fi
  done < <(find .claude/agent-memory -name 'MEMORY.md' -type f 2>/dev/null)
else
  info "No .claude/agent-memory/ yet. Normal before any agent has been invoked."
fi
if [ -f "$PLAYBOOK/knowledge/PROJECT-OVERVIEW.md" ]; then
  ok "PROJECT-OVERVIEW.md exists (bootstrap Phase 7 completed)."
else
  warn "No $PLAYBOOK/knowledge/PROJECT-OVERVIEW.md. The bootstrap wizard has not finished Phase 7."
fi
BLOCK_FOUND=0
for claude_md in ".claude/CLAUDE.md" "CLAUDE.md"; do
  if [ -f "$claude_md" ] && grep -q 'playbook:start' "$claude_md"; then
    ok "$claude_md holds the playbook block, so every session learns the team exists."
    BLOCK_FOUND=1
  fi
done
if [ "$BLOCK_FOUND" -eq 0 ]; then
  warn "No playbook block in CLAUDE.md or .claude/CLAUDE.md. Sessions will not know about the team."
  info "The wizard writes it in Phase 7 (it merges into an existing file, never replaces it)."
fi
# .project/ holds a nested clone and private persona files. In a git repo it must
# be ignored, or one 'git add .' commits all of it.
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if git check-ignore -q .project 2>/dev/null; then
    ok ".project/ is gitignored."
  else
    warn ".project/ is not gitignored. Add '.project/' to .gitignore before your next commit."
  fi
fi
if [ -f "AGENTS.md" ]; then
  ok "AGENTS.md present at the project root."
else
  warn "No AGENTS.md at the project root. Copy it from $PLAYBOOK/AGENTS.md so AI tools find the entry point."
fi

# ---------- Check 7. Context baseline ----------
echo
info "Check 7. Context baseline (what loads into every session before the first prompt)."
# CLAUDE.md loads in full at session start. Anthropic's guidance is under 200 lines.
for claude_md in ".claude/CLAUDE.md" "CLAUDE.md"; do
  [ -f "$claude_md" ] || continue
  md_lines="$(wc -l < "$claude_md")"
  if [ "$md_lines" -gt 200 ]; then
    warn "$claude_md is $md_lines lines. It loads in full every session; aim for under 200 and"
    warn "move workflow detail into skills or rule docs."
  else
    ok "$claude_md is $md_lines lines (under the 200-line guidance)."
  fi
done
# An agent with no model line inherits the main session's model, usually the most
# expensive one. The shipped definitions all pin one.
if [ -d "$AGENT_DST" ]; then
  UNPINNED=0
  for agent_file in "$AGENT_DST"/*.md; do
    [ -f "$agent_file" ] || continue
    if ! awk '/^---[[:space:]]*$/{c++; next} c==1' "$agent_file" | grep -qE '^model:[[:space:]]*[^[:space:]]'; then
      warn "Agent '$(basename "$agent_file" .md)' has no model line, so it inherits the main session's model."
      UNPINNED=$((UNPINNED + 1))
    fi
  done
  [ "$UNPINNED" -eq 0 ] && ok "Every installed agent pins its model."
fi
# Skill descriptions load into every session. No documented limit exists, so this
# is reported, not judged.
SKILL_COUNT=0
SKILL_BYTES=0
for skills_dir in "$HOME/.claude/skills" ".claude/skills"; do
  [ -d "$skills_dir" ] || continue
  for skill_md in "$skills_dir"/*/SKILL.md; do
    [ -f "$skill_md" ] || continue
    SKILL_COUNT=$((SKILL_COUNT + 1))
    fm_bytes="$(awk '/^---[[:space:]]*$/{c++; next} c==1' "$skill_md" | wc -c)"
    SKILL_BYTES=$((SKILL_BYTES + fm_bytes))
  done
done
info "$SKILL_COUNT skills load a description into every session (about $((SKILL_BYTES / 1024))KB of frontmatter;"
info "plugin skills not counted). To turn off ones this project does not use, see skillOverrides"
info "in $PLAYBOOK/reference/rules/CONTEXT-ECONOMY.md, Rule 2."

# ---------- Summary ----------
echo
if [ "$ERRORS" -gt 0 ]; then
  err "Verification failed: $ERRORS error(s), $WARNINGS warning(s). Fix the errors above and re-run."
  exit 1
fi
if [ "$WARNINGS" -gt 0 ]; then
  ok "Verification passed with $WARNINGS warning(s). Read them above; none block work."
else
  ok "Verification passed clean. Everything the installers should have produced is in place."
fi
