# Deployment Guide

This guide covers deploying the auth0-demo-v2 application:

- **Frontend** (React + Vite) → [Vercel](https://vercel.com)
- **Backend** (Sinatra + Puma) → [Render](https://render.com)
- **Auth** → Auth0 (existing tenant)

---

## Prerequisites

- Auth0 tenant with an SPA application and a custom API configured (see [auth0-setup.md](./auth0-setup.md))
- GitHub repository connected to both Vercel and Render
- Vercel account (free tier works)
- Render account (free tier works)

---

## Step 1 — Deploy the Backend to Render

### 1.1 Create a new Web Service

1. In the Render dashboard, click **New → Web Service**
2. Connect your GitHub repository
3. Set the **Root Directory** to `backend`
4. Configure the service:

| Setting | Value |
|---|---|
| Runtime | Ruby |
| Build Command | `bundle install` |
| Start Command | `bundle exec puma -p $PORT` |
| Instance Type | Free (or higher) |

> The `Procfile` in `backend/` provides the start command automatically if Render detects it.

### 1.2 Set environment variables

In the Render dashboard under **Environment**, add:

| Variable | Value |
|---|---|
| `AUTH0_DOMAIN` | `<your-tenant>.us.auth0.com` |
| `AUTH0_AUDIENCE` | `<your-api-identifier>` (e.g. `https://auth0-demo-api`) |
| `FRONTEND_ORIGIN` | `https://<your-vercel-app>.vercel.app` _(set after Step 2)_ |

> `dotenv` is only used locally. Render injects environment variables directly — no `.env` file needed in production.

### 1.3 Note your Render URL

After the first deploy succeeds, copy the service URL (e.g. `https://auth0-demo-v2.onrender.com`). You'll need it for the frontend.

---

## Step 2 — Deploy the Frontend to Vercel

### 2.1 Create a new Vercel project

1. In the Vercel dashboard, click **Add New → Project**
2. Import your GitHub repository
3. Set the **Root Directory** to `frontend`
4. Vercel auto-detects Vite — confirm the framework preset

| Setting | Value |
|---|---|
| Framework Preset | Vite |
| Build Command | `npm run build` |
| Output Directory | `dist` |

### 2.2 Set environment variables

In the Vercel dashboard under **Settings → Environment Variables**, add:

| Variable | Value |
|---|---|
| `VITE_AUTH0_DOMAIN` | `<your-tenant>.us.auth0.com` |
| `VITE_AUTH0_CLIENT_ID` | `<your-spa-client-id>` |
| `VITE_AUTH0_AUDIENCE` | `<your-api-identifier>` (must match backend `AUTH0_AUDIENCE`) |
| `VITE_API_BASE_URL` | `https://<your-render-service>.onrender.com` |

> All `VITE_` variables are inlined at build time. A redeploy is required after changing them.

### 2.3 Note your Vercel URL

After deployment, copy the production URL (e.g. `https://auth0-demo-v2.vercel.app`).

---

## Step 3 — Update Auth0 Application Settings

In the Auth0 dashboard, go to **Applications → your SPA application → Settings** and update:

| Field | Add |
|---|---|
| Allowed Callback URLs | `https://<your-vercel-app>.vercel.app` |
| Allowed Logout URLs | `https://<your-vercel-app>.vercel.app` |
| Allowed Web Origins | `https://<your-vercel-app>.vercel.app` |

Click **Save Changes**.

---

## Step 4 — Update CORS on the Backend

Go back to the Render dashboard and update the `FRONTEND_ORIGIN` environment variable to your production Vercel URL:

```
FRONTEND_ORIGIN=https://<your-vercel-app>.vercel.app
```

Render will automatically restart the service. No code changes are needed — CORS is already configured to read from this variable in `backend/config.ru`.

---

## Environment Variable Reference

### Backend (Render)

| Variable | Description | Example |
|---|---|---|
| `AUTH0_DOMAIN` | Auth0 tenant domain | `dev-abc123.us.auth0.com` |
| `AUTH0_AUDIENCE` | API identifier registered in Auth0 | `https://auth0-demo-api` |
| `FRONTEND_ORIGIN` | Production frontend URL (for CORS) | `https://myapp.vercel.app` |

### Frontend (Vercel)

| Variable | Description | Example |
|---|---|---|
| `VITE_AUTH0_DOMAIN` | Auth0 tenant domain | `dev-abc123.us.auth0.com` |
| `VITE_AUTH0_CLIENT_ID` | SPA application client ID | `xxIyq1oF...` |
| `VITE_AUTH0_AUDIENCE` | API identifier (must match backend) | `https://auth0-demo-api` |
| `VITE_API_BASE_URL` | Backend base URL | `https://myapi.onrender.com` |

---

## CORS Configuration Notes

CORS is handled at the middleware level in `backend/config.ru` via `rack-cors`. In production:

- Only the exact origin set in `FRONTEND_ORIGIN` is allowed — no wildcards
- Allowed methods: `GET`, `POST`, `PUT`, `DELETE`, `OPTIONS`
- Allowed headers: `Authorization`, `Content-Type`
- No source code changes are needed to configure CORS for production

---

## Deployment Verification Checklist

Use this checklist after each deployment to confirm the full auth flow is working.

### Backend (Render)
- [ ] Render service status shows **Live**
- [ ] `GET https://<render-url>/profile` (no token) returns `401 Unauthorized`
- [ ] Build logs show no bundle install errors

### Frontend (Vercel)
- [ ] Vercel deployment status shows **Ready**
- [ ] Production URL loads the landing page
- [ ] Build logs show no Vite/npm errors

### Auth0 Configuration
- [ ] Allowed Callback URLs includes the Vercel production URL
- [ ] Allowed Logout URLs includes the Vercel production URL
- [ ] Allowed Web Origins includes the Vercel production URL

### End-to-End Flow
- [ ] Clicking **Login** redirects to Auth0 Universal Login
- [ ] After authenticating, the app redirects back to the Vercel URL
- [ ] The **Profile** page loads and displays user data (name, email)
- [ ] Browser DevTools console shows no CORS errors
- [ ] Network tab shows `GET /profile` returning `200 OK` with a valid JSON body
- [ ] Clicking **Logout** clears the session and returns to the home page

---

## Troubleshooting

**CORS error in browser console**
- Confirm `FRONTEND_ORIGIN` on Render exactly matches your Vercel URL (no trailing slash)
- Trigger a Render redeploy after updating the variable

**`401 Unauthorized` on `/profile` after login**
- Confirm `AUTH0_AUDIENCE` on Render matches `VITE_AUTH0_AUDIENCE` on Vercel exactly
- Check that the Auth0 API identifier is correct in the Auth0 dashboard

**Auth0 callback error after login**
- Ensure the Vercel URL is listed under **Allowed Callback URLs** in Auth0
- URLs are comma-separated; check for extra spaces or missing `https://`

**Blank page on Vercel after direct URL navigation**
- Confirm `frontend/vercel.json` is committed and contains the SPA rewrite rule

**Environment variables not picked up by Vite**
- `VITE_` variables are baked in at build time — redeploy after any change
- Verify they are set for the **Production** environment in Vercel settings
