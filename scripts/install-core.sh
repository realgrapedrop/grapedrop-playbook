#!/usr/bin/env bash
# Universal-core setup helper for the playbook.
# Does what it can automatically, pauses for what requires manual action
# (Claude Code plugin install, browser-OAuth login).
#
# Run from your project root after dropping .project/playbook/ into your project:
#
#   bash .project/playbook/scripts/install-core.sh
#
# Safe to re-run. The script checks state at each step and skips anything already done.
# Works on macOS, Linux, and Git Bash or WSL on Windows.
#
# Companion script for project-specific domain skills:
#
#   bash .project/playbook/scripts/install-skills.sh <pack>
#
# Run install-skills.sh after this one completes.

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
pause_until_ready() { printf '\n%bPress Enter once that step is complete to continue...%b ' "$C_YEL" "$C_OFF"; read -r _; }

# ---------- Platform detection ----------
OS_NAME="$(uname -s)"
case "$OS_NAME" in
  Darwin)               PLATFORM="macos" ;;
  Linux)                PLATFORM="linux" ;;
  MINGW*|MSYS*|CYGWIN*) PLATFORM="windows" ;;
  *)                    PLATFORM="unknown" ;;
esac
info "Detected platform: $PLATFORM"

# ---------- Step 1. Claude Code ----------
echo
info "Step 1. Verify Claude Code is installed."
if command -v claude >/dev/null 2>&1; then
  ok "Claude Code present: $(claude --version 2>/dev/null || echo 'version unknown')"
else
  err "Claude Code not found on PATH."
  info "Install from https://docs.claude.com/en/docs/claude-code then re-run this script."
  exit 1
fi

# ---------- Step 2. superpowers plugin ----------
echo
info "Step 2. Verify the superpowers plugin is installed."
SUPERPOWERS_DIR="$HOME/.claude/plugins/cache/claude-plugins-official/superpowers"
if [ -d "$SUPERPOWERS_DIR" ] && [ -n "$(ls -A "$SUPERPOWERS_DIR" 2>/dev/null)" ]; then
  ok "superpowers plugin present at $SUPERPOWERS_DIR"
else
  warn "superpowers plugin not found."
  info "Plugin installs are not scriptable from outside Claude Code."
  info "Open Claude Code in another terminal:"
  echo
  echo "    claude"
  echo
  info "Then at the Claude Code prompt, run these four commands in order:"
  echo
  echo "    /plugin marketplace add obra/superpowers-marketplace"
  echo "    /plugin install superpowers@superpowers-marketplace"
  echo "    /reload-plugins"
  echo "    /superpowers"
  echo
  info "The last command should list the available superpowers skills."
  pause_until_ready
  if [ -d "$SUPERPOWERS_DIR" ] && [ -n "$(ls -A "$SUPERPOWERS_DIR" 2>/dev/null)" ]; then
    ok "superpowers plugin now present."
  else
    err "Still no superpowers plugin at $SUPERPOWERS_DIR. Re-run this script after install."
    exit 1
  fi
fi

# ---------- Step 3. parallel-cli binary ----------
echo
info "Step 3. Verify the parallel-cli binary is installed."
if command -v parallel-cli >/dev/null 2>&1; then
  ok "parallel-cli present: $(parallel-cli --version 2>/dev/null || echo 'version unknown')"
else
  warn "parallel-cli not found. Picking the best installer for $PLATFORM."
  case "$PLATFORM" in
    macos)
      if command -v brew >/dev/null 2>&1; then
        info "Installing via Homebrew..."
        brew install parallel-web/tap/parallel-cli
      elif command -v pipx >/dev/null 2>&1; then
        info "Installing via pipx..."
        pipx install "parallel-web-tools[cli]" && pipx ensurepath
      elif command -v npm >/dev/null 2>&1; then
        info "Installing via npm..."
        npm install -g parallel-web-cli
      else
        err "No package manager found (brew, pipx, or npm). Install one and re-run."
        exit 1
      fi
      ;;
    linux|windows)
      if command -v pipx >/dev/null 2>&1; then
        info "Installing via pipx..."
        pipx install "parallel-web-tools[cli]" && pipx ensurepath
      elif command -v uv >/dev/null 2>&1; then
        info "Installing via uv..."
        uv tool install "parallel-web-tools[cli]"
      elif command -v npm >/dev/null 2>&1; then
        info "Installing via npm..."
        npm install -g parallel-web-cli
      else
        err "No package manager found (pipx, uv, or npm). Install one and re-run."
        exit 1
      fi
      ;;
    *)
      err "Unknown platform. Install parallel-cli manually and re-run."
      exit 1
      ;;
  esac
  ok "parallel-cli installed: $(parallel-cli --version 2>/dev/null || echo 'version unknown')"
fi

# ---------- Step 4. parallel-cli auth ----------
echo
info "Step 4. Verify parallel-cli is authenticated."
AUTH_OUT="$(parallel-cli auth --json 2>/dev/null || echo '{}')"
if echo "$AUTH_OUT" | grep -q '"authenticated":[[:space:]]*true'; then
  ok "parallel-cli authenticated."
else
  warn "parallel-cli not authenticated. Browser OAuth required."
  info "Running: parallel-cli login"
  parallel-cli login || true
  AUTH_OUT="$(parallel-cli auth --json 2>/dev/null || echo '{}')"
  if echo "$AUTH_OUT" | grep -q '"authenticated":[[:space:]]*true'; then
    ok "Authentication confirmed."
  else
    err "Still not authenticated. Run 'parallel-cli login' manually and re-run this script."
    exit 1
  fi
fi

# ---------- Step 5. parallel-cli balance ----------
echo
info "Step 5. Check parallel-cli balance."
BAL_OUT="$(parallel-cli balance get 2>/dev/null || echo '')"
if [ -n "$BAL_OUT" ]; then
  ok "Balance check returned: $BAL_OUT"
  info "If the balance is zero or low, add credit at https://platform.parallel.ai/settings"
else
  warn "Could not read balance. Check your account at https://platform.parallel.ai/settings"
fi

# ---------- Step 6. parallel-agent-skills plugin ----------
echo
info "Step 6. Verify the parallel-agent-skills plugin is installed."
PARALLEL_SKILLS_DIR="$HOME/.claude/plugins/cache/parallel-agent-skills/parallel"
if [ -d "$PARALLEL_SKILLS_DIR" ] && [ -n "$(ls -A "$PARALLEL_SKILLS_DIR" 2>/dev/null)" ]; then
  ok "parallel-agent-skills plugin present at $PARALLEL_SKILLS_DIR"
else
  warn "parallel-agent-skills plugin not found. Installing via parallel-cli..."
  parallel-cli skills install
  if [ -d "$PARALLEL_SKILLS_DIR" ] && [ -n "$(ls -A "$PARALLEL_SKILLS_DIR" 2>/dev/null)" ]; then
    ok "parallel-agent-skills installed."
  else
    err "Install completed but plugin directory still missing. Investigate manually."
    exit 1
  fi
fi

# ---------- Step 7. loop-engineering skill ----------
echo
info "Step 7. Verify the loop-engineering skill is installed."
LOOP_SKILL_DIR="$HOME/.agents/skills/loop-engineering"
if [ -d "$LOOP_SKILL_DIR" ] && [ -n "$(ls -A "$LOOP_SKILL_DIR" 2>/dev/null)" ]; then
  ok "loop-engineering skill present at $LOOP_SKILL_DIR"
else
  warn "loop-engineering skill not found. Installing via npx skills add..."
  # This step uses 'npx skills add', which needs Node 20+. The rest of the core
  # does not, so a missing or old Node is a warn-and-skip here, not a hard failure:
  # the universal core still completes and loop-engineering can be added later.
  NODE_OK=0
  if command -v node >/dev/null 2>&1; then
    NODE_MAJOR="$(node -v | sed 's/^v//' | cut -d. -f1)"
    if [ "${NODE_MAJOR}" -ge 20 ] 2>/dev/null; then NODE_OK=1; fi
  fi
  if [ "$NODE_OK" -eq 1 ]; then
    npx --yes skills add invincible04/awesome-loop-engineering --skill loop-engineering --yes --global </dev/null || true
    if [ -d "$LOOP_SKILL_DIR" ] && [ -n "$(ls -A "$LOOP_SKILL_DIR" 2>/dev/null)" ]; then
      ok "loop-engineering skill installed."
    else
      warn "loop-engineering install did not complete. Add it later with:"
      echo "    npx skills add invincible04/awesome-loop-engineering --skill loop-engineering --yes --global"
    fi
  else
    warn "Node.js 20+ not found. Skipping loop-engineering (the rest of the core is unaffected)."
    info "Install Node 20+ from https://nodejs.org, then re-run this script or run:"
    echo "    npx skills add invincible04/awesome-loop-engineering --skill loop-engineering --yes --global"
  fi
fi

# ---------- Done ----------
echo
ok "Universal core setup complete."
echo
info "Open or re-open Claude Code and run /reload-plugins to pick up any new skills."
echo
info "Next steps."
echo "  1. (Optional) Install project-specific domain skills:"
echo
echo "       bash .project/playbook/scripts/install-skills.sh <pack>"
echo
echo "     Available packs: xrpl, xrpl-hooks, frontend, baseline."
echo "     Run with no args to see the full pack descriptions, or browse"
echo "     .project/playbook/reference/tools/SKILLS-INVENTORY.md for individual skills."
echo
echo "  2. Run the bootstrap script from inside Claude Code (see docs/USER-GUIDE.md Step 4):"
echo
echo "       Read .project/playbook/START-PLAYBOOK.md and walk me through it"
echo "       step by step. I am new to all this. Pause for my approval at every"
echo "       meaningful step."
echo
