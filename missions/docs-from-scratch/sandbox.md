---
evaluator:
  command: find docs/ -name '*.md' | wc -l && cat README.md | wc -l
  format: json
  keep_policy: always
---

Focus only on documentation — writing, organizing, and verifying docs.

Allowed changes:
- docs/**/*.md
- README.md
- CONTRIBUTING.md
- src/**/*.ts, src/**/*.js (JSDoc/docstring comments only)

Avoid:
- Code changes, refactoring, or feature development
- Modifying source code logic (adding inline doc comments is OK)
- Removing or overwriting existing documentation without preserving its content
- Generating docs that repeat information already covered elsewhere
