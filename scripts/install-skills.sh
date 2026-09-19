#!/usr/bin/env bash
# Domain-skills install helper for the playbook.
# Installs one or more starter packs of npx-based Claude Code skills.
#
# Run from your project root after install-core.sh has completed:
#
#   bash .project/playbook/scripts/install-skills.sh <pack> [<pack> ...]
#
# Available packs:
#   xrpl              XRPL SaaS baseline (xrpl-dev-skills + resend + sast)
#   xrpl-hooks        XRPL SaaS with Xahau Hooks (same skills as xrpl; Hooks knowledge via URL refs)
#   frontend          Frontend-heavy SaaS (Next.js 15 + shadcn/ui)
#   baseline          Production-ready baseline for any SaaS (sast + sentry + resend)
#   all               Install all four packs above (shorthand for: xrpl xrpl-hooks frontend baseline)
#
# Multiple packs can be combined:
#
#   bash .project/playbook/scripts/install-skills.sh xrpl frontend
#   bash .project/playbook/scripts/install-skills.sh all
#
# For individual skills not in any pack, see .project/playbook/reference/tools/SKILLS-INVENTORY.md
# (the canonical inventory) and run the install commands directly from
# .project/playbook/scripts/MANUAL-INSTALL.md Part 2 Catalog section.
#
# Safe to re-run; `npx skills add` is idempotent for already-installed skills.

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

usage() {
  cat <<'EOF'

Usage: bash .project/playbook/scripts/install-skills.sh <pack> [<pack> ...]

Available starter packs:

  xrpl              XRPL SaaS baseline
                    Installs:
                      - XRPL-Commons/xrpl-dev-skills
                      - resend/resend-skills
                      - utkusen/sast-skills

  xrpl-hooks        XRPL SaaS with Xahau Hooks
                    Installs the same skills as xrpl. Hooks-specific knowledge
                    comes via WebFetch URL references, not an installable skill;
                    the pack prints those URLs at the end as a reminder.
                    Installs:
                      - XRPL-Commons/xrpl-dev-skills
                      - resend/resend-skills
                      - utkusen/sast-skills

  frontend          Frontend-heavy SaaS (Next.js 15 + shadcn/ui)
                    Installs:
                      - anthropics/claude-code (frontend-design)
                      - vercel-labs/agent-skills (web-design-guidelines)
                      - vercel-labs/agent-skills (vercel-react-best-practices)
                      - shadcn/ui
                      - nextlevelbuilder/ui-ux-pro-max-skill
                      - anthropics/skills (web-artifacts-builder)

  baseline          Production-ready baseline for any SaaS
                    Installs:
                      - utkusen/sast-skills
                      - getsentry/skills
                      - resend/resend-skills

  all               Shorthand for: xrpl xrpl-hooks frontend baseline
                    Installs every pack (10 distinct skill repos). Several repos
                    ship many skills each, so this lands around 65 skills, and
                    every skill's description loads into every session. Prefer
                    naming only the packs the project needs; see
                    reference/rules/CONTEXT-ECONOMY.md.
                    Overlapping repos (resend, sast, xrpl-dev-skills) are installed
                    once thanks to npx skills add idempotency, just printed multiple
                    times in the log.

Combine packs by passing multiple names:

  bash .project/playbook/scripts/install-skills.sh xrpl frontend
  bash .project/playbook/scripts/install-skills.sh all

For individual skills not in any pack, see
.project/playbook/reference/tools/SKILLS-INVENTORY.md (canonical inventory) and
.project/playbook/scripts/MANUAL-INSTALL.md Part 2 Catalog section
(copy-paste install commands).
EOF
}

# ---------- Argument check ----------
if [ $# -eq 0 ]; then
  err "No starter pack specified."
  usage
  exit 1
fi

case "${1:-}" in
  -h|--help|help)
    usage
    exit 0
    ;;
esac

# ---------- Pre-flight: Node 20+ ----------
echo
info "Pre-flight: verify Node.js >= 20 is installed."
if command -v node >/dev/null 2>&1; then
  NODE_VER=$(node -v | sed 's/^v//' | cut -d. -f1)
  if [ "${NODE_VER}" -ge 20 ] 2>/dev/null; then
    ok "Node $(node -v) present."
  else
    err "Node $(node -v) is too old. 'npx skills add' requires Node 20 or newer."
    err "Install Node 20+ from https://nodejs.org or via your platform's package manager, then re-run."
    exit 1
  fi
else
  err "Node.js not found on PATH."
  err "'npx skills add' requires Node 20 or newer."
  err "Install Node 20+ from https://nodejs.org or via your platform's package manager, then re-run."
  exit 1
fi

# ---------- Pre-flight: universal core ----------
echo
info "Pre-flight: verify universal core is in place."
if ! command -v claude >/dev/null 2>&1; then
  err "Claude Code not found on PATH. Run 'bash .project/playbook/scripts/install-core.sh' first."
  exit 1
fi
ok "Claude Code present: $(claude --version 2>/dev/null || echo 'version unknown')"

if [ ! -d "$HOME/.claude/plugins/cache/claude-plugins-official/superpowers" ]; then
  warn "superpowers plugin cache not found. Recommended: run install-core.sh first."
else
  ok "superpowers plugin cache present."
fi

if [ ! -d "$HOME/.claude/plugins/cache/parallel-agent-skills/parallel" ]; then
  warn "parallel-agent-skills plugin cache not found. Recommended: run install-core.sh first."
else
  ok "parallel-agent-skills plugin cache present."
fi

# ---------- Skill install runner ----------
install_skill() {
  local label="$1"; shift
  echo
  info "Installing: $label"
  if "$@" </dev/null; then
    ok "Installed: $label"
  else
    err "Failed: $label"
    return 1
  fi
}

# ---------- Pack definitions ----------
run_pack_xrpl() {
  echo
  info "Pack: xrpl (XRPL SaaS baseline)"
  install_skill "XRPL-Commons/xrpl-dev-skills" \
    npx --yes skills add https://github.com/XRPL-Commons/xrpl-dev-skills --yes --global
  install_skill "resend/resend-skills" \
    npx --yes skills add resend/resend-skills --yes --global
  install_skill "utkusen/sast-skills" \
    npx --yes skills add utkusen/sast-skills --yes --global
}

run_pack_xrpl_hooks() {
  echo
  info "Pack: xrpl-hooks (XRPL SaaS with Xahau Hooks)"
  install_skill "XRPL-Commons/xrpl-dev-skills" \
    npx --yes skills add https://github.com/XRPL-Commons/xrpl-dev-skills --yes --global
  install_skill "resend/resend-skills" \
    npx --yes skills add resend/resend-skills --yes --global
  install_skill "utkusen/sast-skills" \
    npx --yes skills add utkusen/sast-skills --yes --global
  echo
  info "Hooks knowledge note. There is no installable Claude skill specifically"
  info "for Xahau Hooks. Claude should fetch these URLs on demand via WebFetch:"
  echo "    https://xrpl-hooks.readme.io/docs/introduction"
  echo "    https://hooks.xrpl.org/"
  info "See .project/playbook/reference/tools/SKILLS-INVENTORY.md \"Domain context beyond"
  info "skills\" for the full URL reference set."
}

run_pack_frontend() {
  echo
  info "Pack: frontend (Frontend-heavy SaaS, Next.js 15 + shadcn/ui)"
  install_skill "anthropics/claude-code (frontend-design)" \
    npx --yes skills add anthropics/claude-code --skill frontend-design --yes --global
  install_skill "vercel-labs/agent-skills (web-design-guidelines)" \
    npx --yes skills add vercel-labs/agent-skills --skill web-design-guidelines --yes --global
  install_skill "vercel-labs/agent-skills (vercel-react-best-practices)" \
    npx --yes skills add vercel-labs/agent-skills --skill vercel-react-best-practices --yes --global
  install_skill "shadcn/ui" \
    npx --yes skills add shadcn/ui --yes --global
  install_skill "nextlevelbuilder/ui-ux-pro-max-skill" \
    npx --yes skills add https://github.com/nextlevelbuilder/ui-ux-pro-max-skill --yes --global
  install_skill "anthropics/skills (web-artifacts-builder)" \
    npx --yes skills add anthropics/skills --skill web-artifacts-builder --yes --global
}

run_pack_baseline() {
  echo
  info "Pack: baseline (Production-ready baseline for any SaaS)"
  install_skill "utkusen/sast-skills" \
    npx --yes skills add utkusen/sast-skills --yes --global
  install_skill "getsentry/skills" \
    npx --yes skills add getsentry/skills --yes --global
  install_skill "resend/resend-skills" \
    npx --yes skills add resend/resend-skills --yes --global
}

# ---------- Dispatch ----------
echo
# Expand the 'all' shorthand into the full pack list before dispatch
EXPANDED_PACKS=()
for pack in "$@"; do
  if [ "$pack" = "all" ]; then
    EXPANDED_PACKS+=(xrpl xrpl-hooks frontend baseline)
  else
    EXPANDED_PACKS+=("$pack")
  fi
done

info "Starter packs to install: ${EXPANDED_PACKS[*]}"

for pack in "${EXPANDED_PACKS[@]}"; do
  case "$pack" in
    xrpl)        run_pack_xrpl ;;
    xrpl-hooks)  run_pack_xrpl_hooks ;;
    frontend)    run_pack_frontend ;;
    baseline)    run_pack_baseline ;;
    *)
      err "Unknown pack: $pack"
      usage
      exit 1
      ;;
  esac
done

# ---------- Done ----------
echo
ok "Domain skills install complete."
echo
info "Next steps."
echo "  1. Open or re-open Claude Code and run /reload-plugins to register the new skills."
echo
echo "  2. Verify the installed skills (npx skills add writes to .agents/skills/,"
echo "     not the same place as the two universal core plugins):"
echo
echo "       ls ~/.agents/skills/         # global install location (default with --global)"
echo "       ls .agents/skills/           # check project-local just in case"
echo "       ls ~/.claude/plugins/cache/  # universal core plugins live here separately"
echo
echo "  3. Add the installed skills to the 'Installed domain skills for this project'"
echo "     section in .project/playbook/reference/tools/SKILLS-INVENTORY.md. The file has the"
echo "     section header and a row format - drop in one row per skill. The inventory"
echo "     is the single source of truth for what tooling this project depends on."
echo "  4. Run the bootstrap script from inside Claude Code if you have not yet (see docs/USER-GUIDE.md Step 4):"
echo
echo "       Read .project/playbook/START-PLAYBOOK.md and walk me through it"
echo "       step by step. I am new to all this. Pause for my approval at every"
echo "       meaningful step."
echo
