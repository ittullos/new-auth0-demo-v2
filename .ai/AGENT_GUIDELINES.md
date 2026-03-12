Default Mode: PLANNING

Agents:

- Planning Agent
- Backend Agent
- Frontend Agent
- Refactor Agent

Rules:

- Only act within assigned role
- Do not modify frontend and backend in the same step
- Small diffs only

Workflow:

- Use feature branches
- Generate commit messages but do not auto-commit

Testing:
Backend changes must include RSpec tests.

Security:
Backend must validate JWT via JWKS.
Never trust frontend tokens.
