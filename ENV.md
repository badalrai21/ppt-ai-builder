# Environment Variables Reference

## Overview

All environment variables should be placed in `.env` file in the root directory. Never commit `.env` to version control.

## Required Variables

### Database

**`DATABASE_URL`** (Required)
- PostgreSQL connection string
- Format: `postgresql://[user]:[password]@[host]:[port]/[database]?[params]`
- Example: `postgresql://user:password@localhost:5432/ppt_ai?schema=public`
- Get from:
  - Local: Create local PostgreSQL database
  - Neon: [neon.tech](https://neon.tech)
  - Supabase: [supabase.com](https://supabase.com)
  - AWS RDS: AWS Console

### Authentication - Better Auth

**`BETTER_AUTH_SECRET`** (Required)
- Secret key for session encryption
- Generate: `openssl rand -base64 32`
- Keep secure and change in production

**`BETTER_AUTH_URL`** (Required)
- Base URL of your application
- Development: `http://localhost:3000`
- Production: `https://your-domain.com`

### Authentication - Google OAuth

**`GOOGLE_CLIENT_ID`** (Required)
- Google OAuth 2.0 Client ID
- Get from: [Google Cloud Console](https://console.cloud.google.com)
- Setup steps:
  1. Create GCP project
  2. Enable Google+ API
  3. Create OAuth 2.0 credential (Web application)
  4. Add authorized redirect URIs:
     - `http://localhost:3000/api/auth/callback/google`
     - `https://your-domain.com/api/auth/callback/google`

**`GOOGLE_CLIENT_SECRET`** (Required)
- Google OAuth 2.0 Client Secret
- Keep secure, never commit to repo

### Authentication - GitHub OAuth (Optional)

**`GITHUB_CLIENT_ID`** (Optional)
- GitHub OAuth App Client ID
- Get from: [GitHub Settings → Developer Settings](https://github.com/settings/developers)
- Setup steps:
  1. Create new OAuth App
  2. Set Authorization callback URL:
     - `http://localhost:3000/api/auth/callback/github`
     - `https://your-domain.com/api/auth/callback/github`

**`GITHUB_CLIENT_SECRET`** (Optional)
- GitHub OAuth App Client Secret
- Keep secure

### AI - Google Generative AI

**`GOOGLE_GENERATIVE_AI_API_KEY`** (Required)
- API key for Google Gemini
- Get from: [Google AI Studio](https://makersuite.google.com/app/apikey)
- Setup steps:
  1. Visit Google AI Studio
  2. Create new API key
  3. Enable Generative Language API
- Usage: Used for generating presentation content

### Image Hosting - ImageKit

**`IMAGEKIT_PUBLIC_KEY`** (Required)
- ImageKit Public Key
- Get from: [ImageKit Dashboard](https://imagekit.io/dashboard)

**`IMAGEKIT_PRIVATE_KEY`** (Required)
- ImageKit Private Key
- Keep secure, used for server-side operations

**`IMAGEKIT_URL_ENDPOINT`** (Required)
- ImageKit URL Endpoint
- Format: `https://ik.imagekit.io/[your-id]`
- Find in ImageKit dashboard

**`IMAGEKIT_BASE_URL`** (Required)
- Same as `IMAGEKIT_URL_ENDPOINT`
- Used for building image URLs

### Background Jobs - Inngest

**`INNGEST_DEV`** (Optional, Development Only)
- Set to `1` for development mode
- Enables local Inngest development server
- Remove or set to `0` in production

**`INNGEST_SIGNING_KEY`** (Production Only)
- Signing key for Inngest webhooks
- Get from: [Inngest Dashboard](https://app.inngest.com)

**`INNGEST_EVENT_KEY`** (Production Only)
- Event key for Inngest API
- Get from Inngest Dashboard

## Optional Variables

### Debugging

**`DEBUG`**
- Enable verbose logging
- Values: `*` (all), `app:*`, etc.
- Useful for development

### Node Environment

**`NODE_ENV`**
- Set to `production` in production
- Automatically set by platforms (Vercel, Railway, etc.)
- Values: `development`, `production`, `test`

**`PORT`**
- HTTP server port
- Default: `3000`
- Override if needed

## Environment Setup Examples

### Local Development

```env
# Database
DATABASE_URL="postgresql://localhost:5432/ppt_ai?schema=public"

# Auth
BETTER_AUTH_SECRET="super-secret-key-generate-this"
BETTER_AUTH_URL="http://localhost:3000"

# Google OAuth
GOOGLE_CLIENT_ID="your-client-id.apps.googleusercontent.com"
GOOGLE_CLIENT_SECRET="your-client-secret"

# Google AI
GOOGLE_GENERATIVE_AI_API_KEY="your-api-key"

# ImageKit
IMAGEKIT_PUBLIC_KEY="public_xxx"
IMAGEKIT_PRIVATE_KEY="private_xxx"
IMAGEKIT_URL_ENDPOINT="https://ik.imagekit.io/your-id"
IMAGEKIT_BASE_URL="https://ik.imagekit.io/your-id"

# Development
INNGEST_DEV=1
DEBUG=ppt-ai:*
```

### Production (Vercel)

```env
# Database (from Neon or Supabase)
DATABASE_URL="postgresql://user:pass@host:5432/db?sslmode=require"

# Auth
BETTER_AUTH_SECRET="generate-strong-secret"
BETTER_AUTH_URL="https://ppt-ai.vercel.app"

# OAuth
GOOGLE_CLIENT_ID="your-prod-client-id"
GOOGLE_CLIENT_SECRET="your-prod-secret"

# AI
GOOGLE_GENERATIVE_AI_API_KEY="your-api-key"

# ImageKit
IMAGEKIT_PUBLIC_KEY="public_xxx"
IMAGEKIT_PRIVATE_KEY="private_xxx"
IMAGEKIT_URL_ENDPOINT="https://ik.imagekit.io/your-id"
IMAGEKIT_BASE_URL="https://ik.imagekit.io/your-id"

# Inngest (from dashboard)
INNGEST_SIGNING_KEY="signkey_xxx"
INNGEST_EVENT_KEY="eventkey_xxx"

# Node
NODE_ENV="production"
```

### Production (Railway)

```env
# Same as Vercel above
# Railway auto-provides DATABASE_URL from PostgreSQL service
# Set other variables in Railway dashboard
```

## Security Best Practices

### Do's ✅

- [ ] Generate strong random secrets: `openssl rand -base64 32`
- [ ] Use different secrets for each environment
- [ ] Rotate secrets periodically
- [ ] Store in secure password manager
- [ ] Use least-privilege OAuth scopes
- [ ] Enable API key restrictions (IP, domains)

### Don'ts ❌

- [ ] Never commit `.env` to Git
- [ ] Never share secrets via Slack, email, etc.
- [ ] Never use same secret across environments
- [ ] Never use weak or placeholder secrets in production
- [ ] Never log secrets to console
- [ ] Never expose secrets in error messages

### .gitignore

Ensure `.env` files are ignored:

```
.env
.env.local
.env.*.local
```

## Validation

### Check Env Variables

```bash
# List all env vars (values hidden)
printenv | grep -E "DATABASE|GOOGLE|IMAGEKIT|BETTER_AUTH|INNGEST"

# Test database connection
node -e "console.log(process.env.DATABASE_URL)" # Should show URL

# Test Prisma client
npx prisma db push --skip-generate
```

### Common Errors

**Error: "Cannot find module or its corresponding type declarations"**
- Missing API key
- Check variable names for typos
- Ensure all required variables are set

**Error: "Failed to connect to database"**
- Check `DATABASE_URL` format
- Test connectivity: `psql $DATABASE_URL`
- Ensure database exists and is accessible

**Error: "OAuth failed"**
- Check client ID and secret
- Verify redirect URLs in OAuth provider settings
- Ensure `BETTER_AUTH_URL` matches configured URL

## Updating Variables

### In Development

1. Edit `.env` file
2. Save file
3. Restart dev server: `npm run dev`

### In Production (Vercel)

1. Go to Vercel Dashboard
2. Project → Settings → Environment Variables
3. Edit variable
4. Redeploy from Git

### In Production (Railway)

1. Go to Railway Dashboard
2. Project → Variables
3. Edit or add variable
4. Auto-redeployed

### In Production (DigitalOcean)

1. Go to App Platform
2. Settings → Environment Variables
3. Edit variable
4. Redeploy

## Environment Rotation

For security, rotate sensitive variables periodically:

```bash
# Step 1: Generate new secret
openssl rand -base64 32

# Step 2: Update in production platform
# (See instructions above)

# Step 3: Verify new value works

# Step 4: Document in team password manager
```

## Troubleshooting

### Variables Not Loading

```bash
# Check .env file exists
cat .env

# Check PATH
echo $PWD

# Verify no spaces in values
grep "=" .env | head -5

# Check for BOM (Windows)
file .env  # Should show "ASCII text"
```

### Conflict with System Variables

Some systems have conflicting variable names:

```bash
# Check current value
echo $DATABASE_URL

# Unset if needed
unset DATABASE_URL

# Source .env manually
export $(cat .env | xargs)
```

### Missing in Production

- Verify variable name matches exactly (case-sensitive)
- Check variable is set in platform dashboard
- Restart application after adding variable
- Check logs for the actual value being used

## References

- [Better Auth Docs](https://www.better-auth.com)
- [Google OAuth Docs](https://developers.google.com/identity/protocols/oauth2)
- [ImageKit Docs](https://docs.imagekit.io)
- [Inngest Docs](https://www.inngest.com/docs)
- [Prisma Docs](https://www.prisma.io/docs)
