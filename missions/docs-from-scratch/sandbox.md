---
evaluator:
  command: find docs/ -name '*.md' | head -20 && wc -l docs/**/*.md README.md 2>/dev/null
  format: text
---

Focus only on documentation — writing, organizing, and verifying docs.
Do not broaden into code changes, refactoring, or feature development.
Do not modify source code files (except adding JSDoc/docstring comments where needed for API doc generation).
Do not remove or overwrite existing documentation without preserving its content.
