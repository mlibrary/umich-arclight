#!/usr/bin/env python3
"""Write a git commit message and invoke git commit -F.

Usage (for AI agents — see AGENTS.md § Git Commit Messages):
  1. Use insert_edit_into_file (or create_file) to write the desired commit
     message to dotpy/commit_msg.txt (subject line + blank line + body).
  2. Run:  python3 dotpy/commit.py | cat

dotpy/commit_msg.txt is listed in .gitignore and is never committed.
This script reads that file and passes it to git commit -F, bypassing all
shell quoting. Never use `git commit -m "..."` for multi-line messages —
zsh mangles quotes and triggers heredoc mode.
"""

import os
import subprocess
import sys
import tempfile
from pathlib import Path

MSG_FILE = Path(__file__).parent / "commit_msg.txt"

if not MSG_FILE.exists():
    print(f"Error: commit message file not found: {MSG_FILE}", file=sys.stderr)
    print("Write your commit message to dotpy/commit_msg.txt first.", file=sys.stderr)
    raise SystemExit(1)

msg = MSG_FILE.read_text(encoding="utf-8")

if not msg.strip():
    print("Error: dotpy/commit_msg.txt is empty.", file=sys.stderr)
    raise SystemExit(1)

with tempfile.NamedTemporaryFile(mode="w", encoding="utf-8", suffix=".txt", delete=False) as f:
    f.write(msg)
    tmp = f.name

try:
    result = subprocess.run(["git", "commit", "-F", tmp])
    raise SystemExit(result.returncode)
finally:
    os.unlink(tmp)
