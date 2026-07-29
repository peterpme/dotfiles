---
name: study-repo
description: Clone a GitHub repo and set up an interactive study session for reading and analyzing the codebase. Use when user says "study repo", "learn this repo", "analyze this codebase", or provides a GitHub URL they want to explore.
argument-hint: <github-url-or-owner/repo> [subpath]
user_invocable: true
---

# study-repo

Clone a GitHub repo and interactively explore it for learning. The repo is the source of truth — ground all answers in actual code.

## Setup Phase

### 1. Parse input

Accept any of:
- `https://github.com/owner/repo`
- `https://github.com/owner/repo.git`
- `owner/repo`
- Just a repo name (ask user to clarify the owner)

Extract `owner` and `repo` from the input.

### 2. Clone or update

Target directory: `~/Projects/<repo>`

```bash
if [ -d ~/Projects/<repo> ]; then
  cd ~/Projects/<repo> && git pull
else
  gh repo clone <owner>/<repo> ~/Projects/<repo>
fi
```

If `gh` is not installed or not authenticated, tell the user to run `gh auth login` and stop.

### 3. Auto-survey (first clone only)

On first clone (directory didn't exist before), generate a repo overview:

1. Show directory tree 1-2 levels deep:
   ```bash
   cd ~/Projects/<repo> && fd --max-depth 2 --type f | head -80
   ```

2. Read the README.md (or README) if it exists

3. Present a concise summary:
   - What the project appears to be (from README)
   - Top-level directory structure
   - Key entry points (package.json main/bin, Makefile, src/index, etc.)

On subsequent sessions (directory already existed, git pull ran), check for `notes/` directory in the repo and read the most recent notes file to restore context.

### 4. Optional subpath focus

If the user provided a subpath argument (e.g., `owner/repo src/core`), focus the survey and subsequent exploration on that subdirectory.

## Study Session

### Answering questions

**Source-of-truth policy: Repo-first, knowledge-second**

- Every factual claim about the codebase MUST cite a specific file (and line when possible)
- Use `rg` and `fd` within `~/Projects/<repo>` to find evidence before answering
- General CS/programming knowledge can be used to EXPLAIN what the code does, but clearly distinguish:
  - "In the repo, `src/parser.ts:42` uses a recursive descent approach" (repo evidence)
  - "Recursive descent parsing is a top-down technique that..." (general knowledge)
- If you can't find evidence in the repo for a claim, say so explicitly
- Never hallucinate file paths, function names, or code that isn't in the repo

### Navigation commands

Throughout the session, the user may ask to:
- Explore a specific file or directory
- Search for patterns or symbols
- Understand how modules connect
- Trace execution flow
- Compare implementations

Use `rg`, `fd`, `Read`, and `Grep` tools extensively. Prefer reading actual code over summarizing from memory.

## Study Notes

### Location

Notes live in `~/Projects/<repo>/notes/*.md` — visible to anyone who clones the repo.

### Auto-save behavior

At the END of every study session (when the conversation is wrapping up or the user switches topics), automatically save/update study notes:

1. Create `notes/` directory if it doesn't exist
2. Write a notes file named by topic or date: `notes/<topic-or-date>.md`
3. Include:
   - Key findings and insights from this session
   - Important files and their purposes discovered
   - Open questions or areas to explore next
   - Architecture patterns identified

### Loading notes on return

When starting a session with an already-cloned repo:
1. Check if `notes/` directory exists
2. If yes, list the files and read the most recent 1-2 notes
3. Briefly summarize prior context: "Last time you explored X and had open questions about Y"

## Example Usage

```
/study-repo facebook/react
/study-repo https://github.com/jotaijs/jotai
/study-repo solidjs/solid src/reactive
```
