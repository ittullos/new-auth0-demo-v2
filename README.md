# auth0-demo-v2

A full-stack Auth0 demo using the Authorization Code Flow with PKCE. The
frontend is a React SPA (Vite + Tailwind) and the backend is a Sinatra API
that validates RS256 JWTs via Auth0's JWKS endpoint.

## Stack

| Layer    | Technology                                          |
| -------- | --------------------------------------------------- |
| Frontend | React 19, Vite, Tailwind CSS v4, @auth0/auth0-react |
| Backend  | Ruby / Sinatra, jwt gem, rack-cors                  |
| Auth     | Auth0 — Authorization Code Flow + PKCE              |
| Testing  | RSpec, rack-test, webmock                           |

## Project Structure

auth0-demo-v2/
├── frontend/ # React + Vite SPA
├── backend/ # Sinatra API
└── docs/ # Architecture and Auth0 setup guides

## Getting Started

### Auth0 Setup

See [docs/auth0-setup.md](docs/auth0-setup.md) for step-by-step Auth0
dashboard configuration.

### Backend

```bash
cd backend
cp .env.example .env
# fill in AUTH0_DOMAIN, AUTH0_AUDIENCE, FRONTEND_ORIGIN
bundle install
bundle exec rackup -p 9292

Frontend

cd frontend
cp .env.example .env.local
# fill in VITE_AUTH0_DOMAIN, VITE_AUTH0_CLIENT_ID, VITE_AUTH0_AUDIENCE
npm install
npm run dev

Tests

cd backend
bundle exec rspec

Architecture

See docs/architecture.md for details on the auth token flow, JWT validation,
CORS strategy, and error response structure.
```
