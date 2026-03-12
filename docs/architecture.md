# Architecture

## 1. Folder Structure

```
auth0-demo-v2/
├── frontend/                   # React + Vite SPA
│   ├── src/
│   │   ├── components/         # Reusable UI components
│   │   ├── hooks/              # Custom React hooks (e.g. useApi)
│   │   └── pages/              # Route-level page components
│   └── vite.config.ts
├── backend/                    # Sinatra API
│   ├── app/
│   │   ├── controllers/        # Route handlers
│   │   └── middleware/         # JWT validation, CORS, error handling
│   ├── spec/                   # RSpec test suite
│   │   ├── middleware/
│   │   ├── controllers/
│   │   └── spec_helper.rb
│   └── config.ru
├── docs/
│   └── architecture.md
├── .ai/
│   └── AGENT_GUIDELINES.md
└── claude.md
```

---

## 2. Auth Token Flow

This project uses the **Authorization Code Flow with PKCE** — appropriate for public clients (SPAs) that cannot hold a client secret.

```
User → Login button
     → Frontend redirects to Auth0 Universal Login (with code_challenge)
     → User authenticates
     → Auth0 redirects to /callback with authorization code
     → Frontend exchanges code + code_verifier for tokens (PKCE, no secret)
     → Frontend receives access_token + id_token
     → access_token stored in memory (never localStorage or cookies)
     → All API requests include: Authorization: Bearer <access_token>
```

Key constraints:
- `code_verifier` / `code_challenge` generated fresh per login attempt
- `access_token` is scoped to the backend API audience
- `id_token` is for frontend display only — never sent to the backend

---

## 3. Backend JWT Validation Flow

Every protected Sinatra route passes through the JWT validation middleware before the handler runs.

```
Incoming request
  → Extract Authorization header → "Bearer <token>"
  → Decode JWT header (without verification) → extract kid
  → Fetch JWKS from https://<AUTH0_DOMAIN>/.well-known/jwks.json
      (cached in memory; re-fetched only on cache miss or key rotation)
  → Match kid to public key in JWKS
  → Verify JWT:
      - Signature (RS256)
      - iss == "https://<AUTH0_DOMAIN>/"
      - aud == "<API_AUDIENCE>"
      - exp > now
  → Pass to route handler on success
  → Return 401 on any failure
```

The backend never trusts a token that has not passed all four claim checks. Frontend-provided tokens are treated as untrusted input.

---

## 4. CORS Strategy

CORS is configured at the middleware level in Sinatra before any route is evaluated.

| Setting | Value |
|---|---|
| Allowed origin | `FRONTEND_ORIGIN` env var (no wildcard `*` in production) |
| Allowed methods | `GET, POST, PUT, DELETE, OPTIONS` |
| Allowed headers | `Authorization, Content-Type` |
| Preflight (`OPTIONS`) | Returns `200` immediately with CORS headers |

The `FRONTEND_ORIGIN` variable must be set explicitly in each environment. Requests from unknown origins are rejected before JWT validation runs.

---

## 5. Testing Strategy (RSpec)

All backend changes follow a **TDD workflow** — specs are written before implementation.

**Test types:**

| Type | Location | Purpose |
|---|---|---|
| Unit | `spec/middleware/` | JWT validation logic; JWKS responses are mocked |
| Request | `spec/controllers/` | Full route coverage via `rack-test` |
| Helpers | `spec/support/` | JWT factory for generating signed valid/invalid tokens |

**Running tests:**
```bash
bundle exec rspec                    # full suite
bundle exec rspec spec/middleware/   # middleware only
bundle exec rspec --format documentation
```

**Coverage requirements:**
- Every protected endpoint must have a request spec covering: valid token, missing token, expired token, wrong audience
- Middleware unit specs must not make real HTTP calls (stub JWKS endpoint with `webmock`)

---

## 6. Error Response Structure

All error responses from the Sinatra backend are JSON with a consistent shape:

```json
{
  "error": "unauthorized",
  "message": "JWT validation failed: token expired",
  "status": 401
}
```

| Field | Type | Description |
|---|---|---|
| `error` | string | Machine-readable snake_case error code |
| `message` | string | Human-readable description for debugging |
| `status` | integer | Mirrors the HTTP status code |

**Standard error codes:**

| HTTP | `error` value |
|---|---|
| 400 | `bad_request` |
| 401 | `unauthorized` |
| 403 | `forbidden` |
| 404 | `not_found` |
| 422 | `unprocessable_entity` |
| 500 | `internal_server_error` |

The error middleware catches unhandled exceptions and wraps them in this structure before responding, ensuring no raw stack traces are leaked to clients.
