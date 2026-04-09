# Working Rules

## Temporary Test Files

- Do not `git add`, `git commit`, or include temporary test-only files that were created only to implement or debug a new feature or bugfix.
- Before staging or committing, review every changed file and exclude temporary validation artifacts such as ad hoc examples, scratch inputs, one-off fixtures, debug outputs, and throwaway regression files unless the user explicitly asked to keep them.
- If a temporary file was useful during implementation but is not part of the intended deliverable, delete it before staging.
- If there is any doubt whether a newly created file is a real deliverable or only a temporary test aid, ask the user before staging it.
