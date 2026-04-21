# Skill: external-context

> Load external documentation, URLs, or files into agent context. Bring the outside world in.
> Inspired by: oh-my-claudecode (external-context skill)

## When to Trigger

- User says "load this doc", "read this URL", "add context from", "reference this spec"
- When you need API documentation that isn't in the codebase
- When implementing against an external standard (RFC, spec, design doc)
- When a library's behavior is unclear and you need its official docs
- When the user shares a link and expects you to understand its content

## Workflow

### Step 1 — Identify Source

Determine the source type:
- **URL:** Web page, API documentation, blog post, RFC
- **Local file:** File path outside the current project
- **GitHub repo:** File or directory from another repository
- **Cached:** Previously loaded content in `.context/`

### Step 2 — Fetch Content

**For URLs:**
1. Fetch the page content
2. Extract the main content (strip navigation, ads, boilerplate)
3. Convert to clean markdown

**For local files:**
1. Read the file
2. If too large (>50KB), extract relevant sections based on the user's question

**For GitHub repos:**
1. Fetch via GitHub API or raw content URL
2. If a directory, list contents and fetch relevant files

**For cached content:**
1. Check `.context/` for a cached version
2. If found and still fresh (< 24 hours), use it
3. If stale, re-fetch and update cache

### Step 3 — Extract Relevant Sections

Don't dump entire pages. Extract what matters:
- Identify sections relevant to the current task
- Pull out: API signatures, configuration options, examples, gotchas
- Discard: marketing copy, unrelated features, navigation elements

### Step 4 — Summarize and Store

Produce a structured summary:
- **Key facts:** The essential information needed for the task
- **API surface:** Relevant functions, parameters, return types
- **Examples:** Code examples that demonstrate usage
- **Gotchas:** Warnings, common mistakes, known issues

Cache the processed content:
- Save to `.context/{source-slug}.md`
- Include source URL and fetch timestamp
- Expire after 24 hours or on user request

### Step 5 — Make Available

The processed content is now in your context. Reference it naturally when working on the task. Cite the source when making claims based on it.

## Output Format

```markdown
## Context Loaded: {source title}

**Source:** {URL or path}
**Fetched:** {timestamp}
**Cached:** `.context/{slug}.md`

### Summary
{2-3 sentence summary of what this document covers}

### Key Facts
- {fact 1}
- {fact 2}
- {fact 3}

### Relevant API / Configuration
{extracted signatures, options, or config details}

### Examples
{code examples from the source}

### Gotchas
- {warning 1}
- {warning 2}
```

## Rules

- NEVER dump raw HTML or unprocessed web pages into context. Always clean and extract.
- Cache aggressively. Don't re-fetch the same URL multiple times in one session.
- Summarize, don't transcribe. Extract the signal, skip the noise.
- Cite your sources. When using information from loaded context, mention where it came from.
- Respect content size. If a document is huge, load only the relevant sections.
- If a URL is unreachable, say so. Don't fabricate content you couldn't fetch.
- Cache directory `.context/` should be gitignored. Don't commit fetched external content.
- Include fetch timestamp in cached files so staleness can be assessed.

## Not Responsible For

- Deep research across many sources (use autoresearch for that)
- Codebase investigation (use deep-dive or grep directly)
- Downloading and installing dependencies (use doctor or manual setup)
- Monitoring external resources for changes over time
- Summarizing the user's own codebase (use analyst or deep-dive)
