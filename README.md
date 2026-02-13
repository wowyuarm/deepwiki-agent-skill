# deepwiki-agent-skill

A lightweight **AgentSkill** that gives AI agents the ability to query [DeepWiki](https://deepwiki.com) — AI-powered documentation for any public GitHub repository.

**How?** A single bash script that calls the [official DeepWiki MCP server](https://mcp.deepwiki.com/mcp) via plain HTTP (JSON-RPC), replacing the need for an MCP client connection. Same API, zero ceremony.

## Why This Exists

The official DeepWiki MCP server provides powerful repo documentation and Q&A capabilities, but using it normally requires:
- An MCP-compatible client (Claude Code, Cursor, etc.)
- A persistent SSE/WebSocket connection
- MCP protocol handshake

This skill **strips all that away**. It calls the same official endpoint (`https://mcp.deepwiki.com/mcp`) with a single stateless `curl` POST — making DeepWiki accessible to any agent framework, CI pipeline, or shell script.

```
Agent invokes deepwiki.sh
        │
        ▼
  curl POST (JSON-RPC)  ──►  https://mcp.deepwiki.com/mcp  (official endpoint)
        │                              │
        ◄──────────────────────────────┘
        │                        SSE response
        ▼
  python3 parses JSON  ──►  plain text output
```

## Commands

| Command | Description |
|---------|-------------|
| `deepwiki.sh structure <owner/repo>` | List documentation topics |
| `deepwiki.sh contents <owner/repo>` | View full documentation |
| `deepwiki.sh ask <owner/repo> "question"` | Ask a question about the repo |

Aliases: `s`, `c`, `a`.

## Quick Start

For Agent Frameworks

Copy `SKILL.md` and `scripts/deepwiki.sh` into your agent's skill/tool directory. The agent reads `SKILL.md` to understand when and how to invoke the script — no additional configuration needed.

### Standalone

```bash
chmod +x scripts/deepwiki.sh

./scripts/deepwiki.sh structure facebook/react
./scripts/deepwiki.sh ask langchain-ai/langchain "How does the chain abstraction work?"
```

## Requirements

- `curl`
- `python3`
- Internet access to `mcp.deepwiki.com`

## Configuration

| Environment Variable | Default | Description |
|---------------------|---------|-------------|
| `DEEPWIKI_ENDPOINT` | `https://mcp.deepwiki.com/mcp` | Override the API endpoint |

## Acknowledgements

This skill calls the [official DeepWiki MCP server](https://cognition.ai/blog/deepwiki-mcp-server) by [Cognition](https://cognition.ai) — free, no auth required, public repos only.

## License

MIT
