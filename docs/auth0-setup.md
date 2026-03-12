# Auth0 Setup Guide

This guide walks through the Auth0 Dashboard configuration required for this project. The frontend is a React SPA (Vite) and the backend is a Sinatra API. Auth uses the Authorization Code Flow with PKCE.

---

## 1. Create a Single Page Application

1. In the Auth0 Dashboard, go to **Applications → Create Application**
2. Enter a name (e.g. `auth0-demo-v2`)
3. Select **Single Page Application** as the application type
4. Click **Create**

From the application's **Settings** tab, note:

| Value | Environment variable |
|---|---|
| Domain | `VITE_AUTH0_DOMAIN` |
| Client ID | `VITE_AUTH0_CLIENT_ID` |

> No Client Secret is needed — PKCE SPAs are public clients and do not use a secret.

---

## 2. Create an API

1. In the Auth0 Dashboard, go to **APIs → Create API**
2. Enter a **Name** (e.g. `auth0-demo-v2 API`)
3. Set the **Identifier** (e.g. `https://api.auth0-demo-v2.dev`)
   - This is the **audience** — choose a URI-style string; it does not need to be a real URL
4. Leave the signing algorithm as **RS256** (see §6)
5. Click **Create**

| Value | Environment variable |
|---|---|
| Identifier (audience) | `VITE_AUTH0_AUDIENCE` (frontend) |
| Identifier (audience) | `AUTH0_AUDIENCE` (backend) |

---

## 3. Set the API Audience

The frontend must request tokens scoped to the backend API audience. Without this, Auth0 issues an **opaque token** that the backend cannot validate.

When initializing `Auth0Provider` in the React app, pass the audience:

```tsx
<Auth0Provider
  domain={import.meta.env.VITE_AUTH0_DOMAIN}
  clientId={import.meta.env.VITE_AUTH0_CLIENT_ID}
  authorizationParams={{
    redirect_uri: window.location.origin,
    audience: import.meta.env.VITE_AUTH0_AUDIENCE,
  }}
>
```

To verify the audience is correct, decode an access token at [jwt.io](https://jwt.io) and confirm the `aud` claim matches the API Identifier.

---

## 4. Configure Callback URLs

Auth0 will only redirect to URLs explicitly listed in **Allowed Callback URLs**. Any other redirect URI will result in a `callback URL mismatch` error.

In the SPA application settings → **Allowed Callback URLs**, add:

```
http://localhost:5173
```

Add production URLs separated by commas when deploying.

---

## 5. Configure Allowed Web Origins

The **Allowed Web Origins** setting permits Auth0 to respond to silent authentication requests (`checkSession`) from the SPA. Without this, token renewal will fail with a cross-origin error.

In the SPA application settings → **Allowed Web Origins**, add:

```
http://localhost:5173
```

Add the production origin when deploying.

> **Note:** This is separate from Allowed Callback URLs. Both must be set.

---

## 6. Ensure RS256 is Enabled

RS256 (asymmetric) allows the backend to verify tokens using Auth0's public JWKS endpoint — no shared secret required.

**For the API:**
- Dashboard → **APIs → [your API] → Settings**
- Confirm **Token Signing Algorithm** is `RS256`
- RS256 is the default; do not change it to HS256

**For the SPA application:**
- Dashboard → **Applications → [your app] → Settings → Advanced Settings → OAuth**
- Confirm **JsonWebToken Signature Algorithm** is `RS256`

**JWKS endpoint** (used by the backend for public key lookup):
```
https://<AUTH0_DOMAIN>/.well-known/jwks.json
```

This URL is public and does not require authentication. The backend fetches it to verify token signatures against the correct RS256 public key.
