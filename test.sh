#!/usr/bin/env bash

# test.sh - Visual demo of all statusline states
# Pipes mock key=value data directly to claude-statusline-render
# No network calls, no side effects, no cache files needed

set -euo pipefail

RENDER="$HOME/.local/bin/claude-statusline-render"

DIM=$'\033[2m'; RESET=$'\033[0m'
label() { printf "\n${DIM}  %s${RESET}\n" "$1"; }

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  claude-statusline  render demo"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ── Project/git line scenarios ───────────────────────────────────────────

label "plain directory, no git"
"$RENDER" <<'EOF'
project_dir=/fake/my-project
model_name=Sonnet 4.6
EOF

label "HOME shows as ~"
"$RENDER" <<EOF
project_dir=$HOME
model_name=Sonnet 4.6
EOF

label "different cwd shows ->subdir arrow"
"$RENDER" <<'EOF'
project_dir=/fake/my-project
current_dir=/fake/my-project/src/components
git_branch=main
git_remote_branch=origin/main
git_has_remote=true
model_name=Sonnet 4.6
EOF

label "Obsidian vault (◆ icon)"
"$RENDER" <<'EOF'
project_dir=/fake/vault
is_obsidian=true
git_branch=main
git_remote_branch=origin/main
git_has_remote=true
model_name=Sonnet 4.6
EOF

label "Obsidian vault + different cwd"
"$RENDER" <<'EOF'
project_dir=/fake/vault
current_dir=/fake/vault/Daily Notes
is_obsidian=true
git_branch=main
git_remote_branch=origin/main
git_has_remote=true
model_name=Sonnet 4.6
EOF

label "Obsidian vault, local-only git"
"$RENDER" <<'EOF'
project_dir=/fake/vault
is_obsidian=true
git_branch=main
git_has_remote=false
model_name=Sonnet 4.6
EOF

label "git with remote (☁ cloud icon)"
"$RENDER" <<'EOF'
project_dir=/fake/my-project
git_branch=main
git_remote_branch=origin/main
git_has_remote=true
model_name=Sonnet 4.6
EOF

label "local-only repo (⌂ home icon)"
"$RENDER" <<'EOF'
project_dir=/fake/local-notes
git_branch=main
git_has_remote=false
model_name=Sonnet 4.6
EOF

label "detached HEAD (short hash)"
"$RENDER" <<'EOF'
project_dir=/fake/my-project
git_branch=a3f9b2c
git_has_remote=false
model_name=Sonnet 4.6
EOF

label "feature branch with remote"
"$RENDER" <<'EOF'
project_dir=/fake/my-project
git_branch=feature/auth-refactor
git_remote_branch=origin/feature/auth-refactor
git_has_remote=true
model_name=Sonnet 4.6
EOF

# ── Ahead / behind ──────────────────────────────────────────────────────

label "ahead of remote (↑3)"
"$RENDER" <<'EOF'
project_dir=/fake/my-project
git_branch=main
git_remote_branch=origin/main
git_ahead=3
git_has_remote=true
model_name=Sonnet 4.6
EOF

label "behind remote (↓2)"
"$RENDER" <<'EOF'
project_dir=/fake/my-project
git_branch=main
git_remote_branch=origin/main
git_behind=2
git_has_remote=true
model_name=Sonnet 4.6
EOF

label "diverged: ahead + behind (↑2 ↓1)"
"$RENDER" <<'EOF'
project_dir=/fake/my-project
git_branch=main
git_remote_branch=origin/main
git_ahead=2
git_behind=1
git_has_remote=true
model_name=Sonnet 4.6
EOF

# ── File status ──────────────────────────────────────────────────────────

label "added files (+3)"
"$RENDER" <<'EOF'
project_dir=/fake/my-project
git_branch=main
git_remote_branch=origin/main
git_added=3
git_has_remote=true
model_name=Sonnet 4.6
EOF

label "deleted files (-2)"
"$RENDER" <<'EOF'
project_dir=/fake/my-project
git_branch=main
git_remote_branch=origin/main
git_deleted=2
git_has_remote=true
model_name=Sonnet 4.6
EOF

label "modified files (5M)"
"$RENDER" <<'EOF'
project_dir=/fake/my-project
git_branch=main
git_remote_branch=origin/main
git_modified=5
git_has_remote=true
model_name=Sonnet 4.6
EOF

label "merge conflicts (2!)"
"$RENDER" <<'EOF'
project_dir=/fake/my-project
git_branch=main
git_remote_branch=origin/main
git_conflicts=2
git_has_remote=true
model_name=Sonnet 4.6
EOF

label "untracked files (4?)"
"$RENDER" <<'EOF'
project_dir=/fake/my-project
git_branch=main
git_remote_branch=origin/main
git_untracked=4
git_has_remote=true
model_name=Sonnet 4.6
EOF

# ── Quota / cost scenarios ───────────────────────────────────────────────

label "no API data (shows only billing block)"
"$RENDER" <<'EOF'
session_cost=12.34
monthly_total=536
days_elapsed=6
days_remaining=22
context_pct=15
model_name=Sonnet 4.6
EOF

label "quota data: green (42% / 65%)"
"$RENDER" <<'EOF'
five_hour_pct=42
five_hour_resets_at=2099-01-01T23:00:00.000Z
seven_day_pct=65
seven_day_resets_at=2099-01-05T00:00:00.000Z
session_cost=12.34
monthly_total=536
days_elapsed=6
days_remaining=22
context_pct=15
model_name=Sonnet 4.6
EOF

label "quota data: yellow (75% / 80%)"
"$RENDER" <<'EOF'
five_hour_pct=75
seven_day_pct=80
sonnet_pct=58
session_cost=5.00
monthly_total=200
days_elapsed=10
days_remaining=18
context_pct=30
model_name=Sonnet 4.6
EOF

label "quota data: red (92% / 95%)"
"$RENDER" <<'EOF'
five_hour_pct=92
seven_day_pct=95
sonnet_pct=88
session_cost=25.00
monthly_total=890
days_elapsed=25
days_remaining=3
context_pct=78
model_name=Sonnet 4.6
EOF

label "with per-model breakdown (H + S + O) - cost-based"
"$RENDER" <<'EOF'
five_hour_pct=42
seven_day_pct=65
sonnet_pct=58
haiku_cost_7d=0.02
opus_cost_7d=5.13
session_cost=12.34
monthly_total=536
days_elapsed=6
days_remaining=22
context_pct=15
model_name=Sonnet 4.6
EOF

label "with per-model breakdown (H only, sub-cent)"
"$RENDER" <<'EOF'
five_hour_pct=42
seven_day_pct=65
sonnet_pct=58
haiku_cost_7d=0.0015
session_cost=0.05
monthly_total=12
days_elapsed=3
days_remaining=25
context_pct=8
model_name=Haiku 4.5
EOF

label "with per-model breakdown (O only, large cost)"
"$RENDER" <<'EOF'
five_hour_pct=80
seven_day_pct=90
opus_cost_7d=42.75
session_cost=42.75
monthly_total=890
days_elapsed=20
days_remaining=8
context_pct=45
model_name=Opus 4.6
EOF

label "with windowed Firebase costs"
"$RENDER" <<'EOF'
five_hour_pct=42
seven_day_pct=65
sonnet_pct=58
cost_5h=$2.50
cost_7d=18¢
session_cost=12.34
monthly_total=536
days_elapsed=6
days_remaining=22
context_pct=15
model_name=Sonnet 4.6
EOF

label "with query cost and model plan"
"$RENDER" <<'EOF'
five_hour_pct=42
seven_day_pct=65
sonnet_pct=58
session_cost=12.34
query_cost=0.45
monthly_total=536
days_elapsed=6
days_remaining=22
context_pct=15
model_name=Sonnet 4.6
model_plan=claude-sonnet-4-5-20250514
EOF

label "with extra overage (green)"
"$RENDER" <<'EOF'
five_hour_pct=42
seven_day_pct=65
extra_enabled=true
extra_used=12
extra_limit=50
session_cost=5.00
monthly_total=300
days_elapsed=10
days_remaining=18
context_pct=20
model_name=Sonnet 4.6
EOF

label "with extra overage (red)"
"$RENDER" <<'EOF'
five_hour_pct=42
seven_day_pct=65
extra_enabled=true
extra_used=47
extra_limit=50
session_cost=5.00
monthly_total=300
days_elapsed=10
days_remaining=18
context_pct=20
model_name=Sonnet 4.6
EOF

# ── Kitchen sink ─────────────────────────────────────────────────────────

label "everything at once"
"$RENDER" <<'EOF'
project_dir=/fake/vault
current_dir=/fake/vault/src
is_obsidian=true
git_branch=feature/big-refactor
git_remote_branch=origin/feature/big-refactor
git_ahead=4
git_behind=2
git_added=3
git_deleted=1
git_modified=7
git_conflicts=1
git_untracked=5
git_has_remote=true
five_hour_pct=42
five_hour_resets_at=2099-01-01T23:00:00.000Z
seven_day_pct=65
seven_day_resets_at=2099-01-05T00:00:00.000Z
sonnet_pct=58
haiku_cost_7d=0.02
opus_cost_7d=5.13
cost_5h=$2.50
cost_7d=18¢
session_cost=12.34
query_cost=0.45
monthly_total=536
days_elapsed=6
days_remaining=22
context_pct=59
model_name=Sonnet 4.6
model_plan=claude-sonnet-4-5-20250514
EOF

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
