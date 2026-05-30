#!/usr/bin/env python3
"""Convert a Letta agent dump (.af JSON) into readable summaries."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path


def load_dump(path: Path) -> dict:
    with path.open("r", encoding="utf-8") as f:
        return json.load(f)


def compact_llm_config(agent: dict) -> dict:
    cfg = agent.get("llm_config") or {}
    return {
        "model": cfg.get("model"),
        "provider": cfg.get("provider_name"),
        "endpoint_type": cfg.get("model_endpoint_type"),
        "endpoint": cfg.get("model_endpoint"),
        "handle": cfg.get("handle"),
        "context_window": cfg.get("context_window"),
        "temperature": cfg.get("temperature"),
        "max_tokens": cfg.get("max_tokens"),
        "reasoning_effort": cfg.get("reasoning_effort"),
        "parallel_tool_calls": cfg.get("parallel_tool_calls"),
    }


def compact_embedding_config(agent: dict) -> dict:
    cfg = agent.get("embedding_config") or {}
    return {
        "model": cfg.get("embedding_model"),
        "endpoint_type": cfg.get("embedding_endpoint_type"),
        "endpoint": cfg.get("embedding_endpoint"),
        "handle": cfg.get("handle"),
        "dim": cfg.get("embedding_dim"),
        "chunk_size": cfg.get("embedding_chunk_size"),
        "batch_size": cfg.get("batch_size"),
    }


def agent_summary(agent: dict) -> dict:
    return {
        "name": agent.get("name"),
        "id": agent.get("id"),
        "description": agent.get("description"),
        "agent_type": agent.get("agent_type"),
        "tags": agent.get("tags") or [],
        "tools": agent.get("tools") or [],
        "tool_ids": agent.get("tool_ids") or [],
        "block_ids": agent.get("block_ids") or [],
        "memory_blocks": agent.get("memory_blocks") or [],
        "source_ids": agent.get("source_ids") or [],
        "folder_ids": agent.get("folder_ids"),
        "llm_config": compact_llm_config(agent),
        "embedding_config": compact_embedding_config(agent),
        "system": agent.get("system"),
    }


def to_markdown(dump: dict) -> str:
    agents = dump.get("agents") or []
    lines = []
    lines.append(f"# Letta Dump: {len(agents)} agent(s)")
    lines.append("")
    for agent in agents:
        summary = agent_summary(agent)
        lines.append(f"## {summary['name'] or 'Unnamed'}")
        lines.append(f"- `id`: `{summary['id']}`")
        if summary["description"]:
            lines.append(f"- `description`: {summary['description']}")
        if summary["agent_type"]:
            lines.append(f"- `type`: `{summary['agent_type']}`")
        if summary["tags"]:
            lines.append(f"- `tags`: {', '.join(f'`{t}`' for t in summary['tags'])}")
        if summary["tools"]:
            lines.append(f"- `tools`: {', '.join(summary['tools'])}")
        if summary["llm_config"]["model"] or summary["llm_config"]["provider"]:
            llm = summary["llm_config"]
            lines.append(
                f"- `llm`: model={llm['model'] or 'n/a'}, provider={llm['provider'] or 'n/a'}, handle={llm['handle'] or 'n/a'}"
            )
        if summary["embedding_config"]["model"]:
            emb = summary["embedding_config"]
            lines.append(
                f"- `embeddings`: model={emb['model']}, handle={emb['handle'] or 'n/a'}"
            )
        if summary["system"]:
            lines.append("")
            lines.append("### System Prompt")
            lines.append("```text")
            lines.append(summary["system"])
            lines.append("```")
        lines.append("")
    return "\n".join(lines).rstrip()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("dump", type=Path, help="Path to the .af JSON dump")
    parser.add_argument("--json", action="store_true", help="Emit compact JSON")
    args = parser.parse_args()

    dump = load_dump(args.dump)
    agents = dump.get("agents") or []

    if args.json:
        json.dump([agent_summary(agent) for agent in agents], sys.stdout, indent=2)
        sys.stdout.write("\n")
    else:
        sys.stdout.write(to_markdown(dump) + "\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
