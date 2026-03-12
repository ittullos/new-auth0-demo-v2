# Claude Project Configuration

Default Mode: PLANNING

Agents:

- Planning Agent
- Backend Agent
- Frontend Agent
- Refactor Agent

Workflow:

- Feature branches only
- No direct commits to main
- Claude may generate commit messages but must not auto-commit

Auth Flow:
Auth0 Authorization Code Flow with PKCE

Backend:
Sinatra API validating JWT via JWKS.

Frontend:
React (Vite) with @auth0/auth0-react.

Testing:
Backend uses RSpec with TDD workflow.
