---
evaluator:
  command: {test command}
  format: json
  keep_policy: pass_only
---

Focus only on {scope description}.

Allowed changes:
- {files/directories the agent MAY modify}

Avoid:
- {things the agent must NOT do}
- {scope boundaries to respect}
