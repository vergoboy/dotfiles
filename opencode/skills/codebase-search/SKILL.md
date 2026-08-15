---
name: codebase-search
description: Semantic search over an indexed codebase using a local RAG tool. Use this when you need to find relevant code by meaning/concept (not just filename), especially in large codebases where reading every file isn't practical. Requires the project to be indexed first.
---

## Workflow

1. Check if the project is already indexed by trying `codebase-rag_search_codebase` with the project's directory name as `table_name`.
2. If no results or an error about a missing table, tell the user to run:
before searching can work.
3. When searching, always call `codebase-rag_search_codebase` with:
   - `table_name`: the project's folder name (e.g. "rust-test-project")
   - `query`: a natural language description of what you're looking for (e.g. "function that validates user input", not just a keyword)
   - `limit`: 5 by default, increase if the first results aren't enough
4. Use this tool INSTEAD OF `glob`/`grep` when the search is about meaning or behavior rather than an exact filename or string match. Still use `glob`/`grep` for exact filename patterns or literal string searches.
5. Prefer this tool proactively for any codebase with more than ~20 files, without waiting to be told to use it explicitly.

## When NOT to use this

- Small projects (a few files) — just read the files directly, it's faster and more accurate.
- When you already know the exact file path.
- When searching for an exact string/regex match — use `grep` instead.
