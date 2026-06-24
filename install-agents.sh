#!/usr/bin/env bash
# Installs the Claude Code multi-agent layer for maieutic-tools.
#
# Run this after installing the skills, e.g.:
#   npx skills@latest add jpab/maieutic-tools -g
#
# The agents/ directory is not handled by the skills CLI — this script copies
# the subagent definitions to ~/.claude/agents/ where Claude Code can find them.
#
# Usage:
#   install-agents.sh                                    # all tools (default)
#   install-agents.sh socratic-dev                       # one tool
#   install-agents.sh socratic-dev dialectic-synthesis   # several tools
#
# Piped form — pass tool names after `-s --`:
#   curl -fsSL .../install-agents.sh | sh                              # all
#   curl -fsSL .../install-agents.sh | sh -s -- socratic-dev          # one tool
#
# Kept POSIX-compatible (no arrays, no pipefail) so it runs under both bash and
# the plain `sh` the piped form invokes.

set -eu

REPO="jpab/maieutic-tools"
BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
AGENTS_DIR="${HOME}/.claude/agents"

ALL_TOOLS="socratic-dev anamnesis-wiki dialectic-synthesis"

# Echo the agent file paths for a given tool, one per line. Unknown tool → exit 1.
agents_for_tool() {
  case "$1" in
    socratic-dev)
      cat <<'EOF'
tools/socratic-dev/agents/task-context.md
tools/socratic-dev/agents/task-evaluator.md
tools/socratic-dev/agents/codebase-context.md
tools/socratic-dev/agents/grill.md
tools/socratic-dev/agents/ideation.md
tools/socratic-dev/agents/implementation.md
tools/socratic-dev/agents/critic.md
EOF
      ;;
    anamnesis-wiki)
      cat <<'EOF'
tools/anamnesis-wiki/agents/wiki-writer.md
EOF
      ;;
    dialectic-synthesis)
      cat <<'EOF'
tools/dialectic-synthesis/agents/goal-elicitation.md
tools/dialectic-synthesis/agents/artifact-reader.md
tools/dialectic-synthesis/agents/tension-mapper.md
tools/dialectic-synthesis/agents/synthesis-planner.md
tools/dialectic-synthesis/agents/synthesis-critic.md
EOF
      ;;
    *)
      return 1
      ;;
  esac
}

# Which tools to install: all by default, or the ones named on the command line.
if [ "$#" -eq 0 ]; then
  TOOLS="${ALL_TOOLS}"
else
  TOOLS="$*"
fi

# Validate tool names before downloading anything.
for tool in ${TOOLS}; do
  if ! agents_for_tool "${tool}" >/dev/null 2>&1; then
    echo "Unknown tool: ${tool}" >&2
    echo "Known tools: ${ALL_TOOLS}" >&2
    exit 1
  fi
done

# Collect the agent paths, de-duplicated (preserving first occurrence) so a
# repeated tool — or a future shared agent — is fetched only once.
selected=""
for tool in ${TOOLS}; do
  for agent_path in $(agents_for_tool "${tool}"); do
    case " ${selected} " in
      *" ${agent_path} "*) : ;;
      *) selected="${selected} ${agent_path}" ;;
    esac
  done
done

echo "Installing maieutic-tools agents to ${AGENTS_DIR}/"
echo "Tools: ${TOOLS}"
mkdir -p "${AGENTS_DIR}"

for agent_path in ${selected}; do
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
