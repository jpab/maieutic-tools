#!/usr/bin/env bash
# Installs the Claude Code multi-agent layer for maieutic-tools.
# Run this after `npx skills@latest add jpab/maieutic-tools -g`.
#
# The agents/ directory is not handled by the skills CLI — this script
# copies the subagent definitions to ~/.claude/agents/ where Claude Code
# can find them.

set -euo pipefail

REPO="jpab/maieutic-tools"
BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
AGENTS_DIR="${HOME}/.claude/agents"

AGENTS=(
  "tools/socratic-dev/agents/task-context.md"
  "tools/socratic-dev/agents/task-evaluator.md"
  "tools/socratic-dev/agents/codebase-context.md"
  "tools/socratic-dev/agents/grill.md"
  "tools/socratic-dev/agents/ideation.md"
  "tools/socratic-dev/agents/implementation.md"
  "tools/socratic-dev/agents/critic.md"
  "tools/anamnesis-wiki/agents/wiki-writer.md"
  "tools/dialectic-synthesis/agents/goal-elicitation.md"
  "tools/dialectic-synthesis/agents/artifact-reader.md"
  "tools/dialectic-synthesis/agents/tension-mapper.md"
  "tools/dialectic-synthesis/agents/synthesis-planner.md"
)

echo "Installing maieutic-tools agents to ${AGENTS_DIR}/"
mkdir -p "${AGENTS_DIR}"

for agent_path in "${AGENTS[@]}"; do
  filename=$(basename "${agent_path}")
  url="${BASE_URL}/${agent_path}"
  dest="${AGENTS_DIR}/${filename}"

  if curl -fsSL "${url}" -o "${dest}"; then
    echo "  ✓ ${filename}"
  else
    echo "  ✗ ${filename} — failed to download from ${url}" >&2
    exit 1
  fi
done

echo ""
echo "Done. Restart Claude Code if it was already running."
