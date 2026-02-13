#!/usr/bin/env bash
# deepwiki.sh — Query DeepWiki API directly via JSON-RPC over HTTP.
# No MCP client, no auth, no dependencies beyond curl + python3.
set -euo pipefail

ENDPOINT="${DEEPWIKI_ENDPOINT:-https://mcp.deepwiki.com/mcp}"

usage() {
    cat <<'EOF'
Usage:
  deepwiki.sh structure <owner/repo>            List documentation topics
  deepwiki.sh contents  <owner/repo>            View full documentation
  deepwiki.sh ask       <owner/repo> "question" Ask a question about the repo

Aliases: s=structure, c=contents, a=ask

Environment:
  DEEPWIKI_ENDPOINT   Override API endpoint (default: https://mcp.deepwiki.com/mcp)
EOF
    exit 1
}

call_tool() {
    local tool_name="$1"
    local arguments="$2"

    local response
    response=$(curl -sf --max-time 120 -X POST "$ENDPOINT" \
        -H "Content-Type: application/json" \
        -H "Accept: application/json, text/event-stream" \
        -d "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"tools/call\",\"params\":{\"name\":\"${tool_name}\",\"arguments\":${arguments}}}")

    if [[ -z "$response" ]]; then
        echo "Error: empty response from API" >&2
        exit 1
    fi

    echo "$response" \
    | sed -n 's/^data: //p' \
    | python3 -c "
import sys, json
data = json.load(sys.stdin)
if 'error' in data:
    print(f\"Error: {data['error'].get('message', 'unknown')}\", file=sys.stderr)
    sys.exit(1)
for item in data.get('result', {}).get('content', []):
    if item.get('type') == 'text':
        print(item['text'])
"
}

[[ $# -lt 2 ]] && usage

cmd="$1"
repo="$2"

case "$cmd" in
    structure|s)
        call_tool "read_wiki_structure" "{\"repoName\":\"${repo}\"}"
        ;;
    contents|c)
        call_tool "read_wiki_contents" "{\"repoName\":\"${repo}\"}"
        ;;
    ask|a)
        [[ $# -lt 3 ]] && { echo "Error: question required" >&2; usage; }
        question=$(python3 -c "import json,sys; print(json.dumps(sys.argv[1]))" "$3")
        call_tool "ask_question" "{\"repoName\":\"${repo}\",\"question\":${question}}"
        ;;
    *)
        echo "Unknown command: $cmd" >&2
        usage
        ;;
esac
