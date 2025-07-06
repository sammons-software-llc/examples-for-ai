# Git Commit Format

Commits should be formatted as such:

```
[Task ID]: <commit description>

<1-3 sentences describing work>

- filename: one-line-desc-of-changes-in-file
```

## Example

```
[TASK-123]: Add user authentication feature

Implemented JWT-based authentication with secure token storage and refresh mechanism.

- src/auth/jwt-service.ts: Added JWT token generation and validation
- src/middleware/auth.ts: Created authentication middleware  
- src/routes/auth.ts: Added login and logout endpoints
- tests/auth.test.ts: Added comprehensive authentication tests
```

## Rules

- ALWAYS work on a feature branch derived from a fresh version of `main`
- NEVER force push to `main`
- ALWAYS reset and re-commit all of the changes for a PR, force pushing to the PR branch so that the commit is exhaustive and 1 commit = 1 PR with a clean and descriptive commit