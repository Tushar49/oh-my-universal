# Mission: Docs from Scratch

Generate comprehensive documentation for an undocumented or poorly documented project. A new developer should be able to onboard from the docs alone.

## Goal

Produce a complete documentation set that covers project purpose, architecture, setup, API reference, and contribution guidelines — enough for a new developer to understand, run, and contribute to the project without asking questions.

## Focus Areas

- README.md (project overview, quick start, badges)
- Architecture documentation (system design, data flow, key decisions)
- API reference (endpoints, functions, types — auto-generated where possible)
- Getting started guide (setup, prerequisites, first run)
- Contributing guide (code style, PR process, testing requirements)

## Success Criteria

1. `wiki` skill produces complete documentation covering all focus areas
2. README.md includes: description, prerequisites, install steps, usage, and license
3. Architecture doc explains the system with at least one diagram (mermaid or ASCII)
4. A new developer can clone, install, and run the project following only the docs
5. All code examples in docs are verified to work (no stale snippets)

## Constraints

- Do not invent or assume features — document only what exists in the codebase
- Do not modify application code to make it more documentable
- Do not generate API docs for internal/private functions unless they are architecturally significant
- Keep docs in markdown format for maximum portability
- Use existing doc conventions if any are already established in the project
