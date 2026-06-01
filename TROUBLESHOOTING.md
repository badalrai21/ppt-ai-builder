# Troubleshooting Guide

## General Troubleshooting

### Application Won't Start

**Error:** `Port already in use`

```bash
# Solution 1: Use different port
npm run dev -- --port 3001

# Solution 2: Kill process using port
lsof -i :3000
kill -9 <PID>
```

**Error:** `Cannot find module`

```bash
# Clear cache and reinstall
rm -rf node_modules
npm install

# Or with pnpm
pnpm install
```

**Error:** `TypeScript compilation errors`

```bash
# Check TypeScript errors
npx tsc --noEmit

# Fix auto-fixable issues
npx tsc --noEmit --listFiles
```

---

## Database Issues

### Database Connection Failed

**Error:** `Failed to connect to PostgreSQL`

**Solutions:**

```bash
# 1. Check connection string
echo $DATABASE_URL

# 2. Test connection
psql $DATABASE_URL

# 3. Verify PostgreSQL is running
pg_isready

# 4. Check credentials
# Format: postgresql://user:password@host:port/db
```

**Error:** `role "user" does not exist`

```bash
# Create PostgreSQL user
createuser -P your-username

# Create database
createdb -O your-username your-database
```

**Error:** `permission denied`

```bash
# Grant privileges
psql -U postgres
GRANT ALL PRIVILEGES ON DATABASE your-database TO your-username;
```

---

### Migration Issues

**Error:** `Migration failed`

```bash
# Check migration status
npx prisma migrate status

# View migration history
npx prisma migrate history

# Resolve conflicts
npx prisma migrate resolve --rolled-back migration-name

# Reset database (development only)
npx prisma migrate reset
```

**Error:** `Prisma client out of sync`

```bash
# Regenerate Prisma client
npx prisma generate

# Then restart dev server
npm run dev
```

---

## Authentication Issues

### Google OAuth Not Working

**Error:** `redirect_uri_mismatch`

**Solutions:**

1. Check Google Cloud Console:
   - Go to [console.cloud.google.com](https://console.cloud.google.com)
   - Select project
   - APIs & Services → Credentials
   - Click OAuth 2.0 Client ID

2. Verify redirect URIs:
   ```
   http://localhost:3000/api/auth/callback/google
   https://your-domain.com/api/auth/callback/google
   ```

3. Check `BETTER_AUTH_URL` in `.env`:
   ```
   BETTER_AUTH_URL=http://localhost:3000
   ```

4. Clear cookies and try again

**Error:** `GOOGLE_CLIENT_ID is undefined`

```bash
# Verify .env file
cat .env | grep GOOGLE

# Check .env is in root directory
pwd
ls -la .env

# Make sure no spaces in values
grep "GOOGLE_CLIENT_ID=" .env
```

### GitHub OAuth Not Working

**Error:** `Client authentication failed`

**Solutions:**

1. Verify credentials in GitHub Settings:
   - Settings → Developer Settings → OAuth Apps
   - Edit Application
   - Check Client ID and Secret

2. Update redirect URL:
   ```
   http://localhost:3000/api/auth/callback/github
   ```

3. Verify `GITHUB_CLIENT_ID` and `GITHUB_CLIENT_SECRET` in `.env`

### Cannot Login / Session Not Persistent

**Error:** `Session cookie not set`

**Solutions:**

```bash
# 1. Check BETTER_AUTH_SECRET
echo $BETTER_AUTH_SECRET
# Should output a value, not empty

# 2. Generate new secret if empty
openssl rand -base64 32

# 3. Update .env
BETTER_AUTH_SECRET="new-secret-here"

# 4. Restart dev server
npm run dev
```

**Error:** `Redirect loop on login`

```bash
# 1. Check BETTER_AUTH_URL
echo $BETTER_AUTH_URL
# Should be http://localhost:3000 for dev

# 2. Clear browser cookies
# Settings → Privacy → Clear browsing data → Cookies

# 3. Restart in incognito window

# 4. Check redirect URL in OAuth provider
```

---

## API & Server Function Issues

### Server Function Returns 500

**Error:** `Internal Server Error`

**Solutions:**

1. Check server logs:
   ```bash
   npm run dev
   # Look for error output
   ```

2. Add error handling:
   ```typescript
   try {
     // function logic
   } catch (error) {
     console.error('Detailed error:', error)
     throw error
   }
   ```

3. Verify all environment variables are set
4. Check database connection

### CORS Error

**Error:** `Access to fetch blocked by CORS`

**Solutions:**

```typescript
// In vite.config.ts, CORS should be auto-configured
// For manual config:
{
  server: {
    cors: true
  }
}
```

### Request Timeout

**Error:** `Request timeout`

**Solutions:**

```bash
# 1. Increase timeout in development
# Depends on hosting platform

# 2. Check API endpoint is responding
curl http://localhost:3000/api/presentations

# 3. Verify database performance
npx prisma studio

# 4. Check internet connection
ping google.com
```

---

## Presentation Generation Issues

### Presentation Status Stuck on "GENERATING"

**Error:** Status never changes to "COMPLETED"

**Solutions:**

1. Check Inngest job status:
   - Visit [app.inngest.com](https://app.inngest.com)
   - Check function runs for errors

2. Verify Google Gemini API:
   ```bash
   # Check API key
   echo $GOOGLE_GENERATIVE_AI_API_KEY
   
   # Verify API is enabled in Google Cloud Console
   # APIs & Services → Enable Google Generative AI
   ```

3. Check database for slide records:
   ```bash
   npx prisma studio
   # Check Slide table for entries
   ```

4. Restart dev server:
   ```bash
   npm run dev
   ```

### Images Not Generating

**Error:** Slides have no images

**Solutions:**

1. Verify ImageKit credentials:
   ```bash
   echo $IMAGEKIT_PUBLIC_KEY
   echo $IMAGEKIT_BASE_URL
   ```

2. Check image generation isn't implemented yet:
   - Current version uses solid backgrounds
   - Image generation requires additional API setup

3. For image implementation, see [DEPLOYMENT.md](./DEPLOYMENT.md)

### Memory Limit Exceeded

**Error:** `JavaScript heap out of memory`

**Solutions:**

```bash
# Increase Node memory
NODE_OPTIONS=--max-old-space-size=4096 npm run build

# Or in package.json
"build": "NODE_OPTIONS=--max-old-space-size=4096 vite build"
```

---

## Build Issues

### Build Fails with Missing Module

**Error:** `Cannot find module '@something/package'`

**Solutions:**

```bash
# 1. Install dependencies
npm install

# 2. Check package.json for typo
cat package.json | grep "@something"

# 3. Install missing package
npm install @something/package

# 4. Clear cache
rm -rf node_modules .nuxt
npm install
```

### Build Fails with TypeScript Error

**Error:** `Type 'X' is not assignable to type 'Y'`

**Solutions:**

```bash
# 1. Check TypeScript version
npm list typescript

# 2. Update TypeScript
npm install -D typescript@latest

# 3. Verify tsconfig.json
cat tsconfig.json

# 4. Generate types
npx prisma generate
```

### Vite Build Too Large

**Error:** `Chunk size warning`

**Solutions:**

```typescript
// In vite.config.ts
export default defineConfig({
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          'react-lib': ['react', 'react-dom'],
          'query-lib': ['@tanstack/react-query'],
        }
      }
    }
  }
})
```

---

## Performance Issues

### Slow Page Load

**Causes & Solutions:**

1. **Large bundle size**
   ```bash
   npm run build
   # Check .output/public size
   ```

2. **Slow database queries**
   ```bash
   # Enable Prisma logging
   # In prisma/schema.prisma
   datasource db {
     logging = ["query", "info"]
   }
   ```

3. **Missing indexes**
   ```prisma
   model Presentation {
     @@index([userId])
     @@index([status])
   }
   ```

### High Memory Usage

**Solutions:**

```bash
# Monitor memory
node --inspect npm run dev
# Open chrome://inspect

# Limit memory
NODE_OPTIONS=--max-old-space-size=2048 npm run dev
```

---

## Deployment Issues

### Deploy Fails on Vercel

**Error:** `Build failed`

**Solutions:**

1. Check build logs in Vercel dashboard
2. Verify environment variables are set
3. Test build locally:
   ```bash
   npm run build
   ```

### Application Works Locally but Not in Production

**Common Causes:**

1. **Missing environment variables**
   - Check all vars are set in platform dashboard

2. **Database connection string**
   - Use `?sslmode=require` for remote databases
   - Format: `postgresql://...?schema=public&sslmode=require`

3. **BETTER_AUTH_URL mismatch**
   - Should match deployed domain
   - Example: `https://ppt-ai.vercel.app`

4. **OAuth redirect URIs**
   - Update in Google Cloud Console and GitHub settings

---

## Debugging Techniques

### Enable Verbose Logging

```bash
# Set DEBUG variable
DEBUG=* npm run dev

# Or specific modules
DEBUG=ppt-ai:* npm run dev
```

### Use Browser DevTools

1. **React DevTools** - Inspect component tree
2. **React Query DevTools** - Monitor queries
3. **TanStack Router DevTools** - Debug routing
4. **Network tab** - Check API calls

### Check Environment

```bash
# List all env vars
env | grep -E "DATABASE|GOOGLE|IMAGEKIT|BETTER_AUTH"

# Test specific var
echo $DATABASE_URL

# Source .env manually
export $(cat .env | xargs)
```

### Database Inspection

```bash
# Open Prisma Studio
npx prisma studio

# Query database directly
psql $DATABASE_URL
SELECT * FROM "Presentation" LIMIT 5;
```

---

## Getting Help

### Before Asking for Help

1. ✅ Check this troubleshooting guide
2. ✅ Read error message carefully
3. ✅ Check relevant documentation file
4. ✅ Search GitHub issues
5. ✅ Try clearing cache and reinstalling

### Where to Get Help

- **GitHub Issues** - Bug reports and feature requests
- **Discussions** - General questions
- **Documentation** - See README.md and other .md files
- **Stack Overflow** - Tag questions with project name

### What to Include When Asking

- Error message (full)
- Steps to reproduce
- Operating system and Node version
- Output of `npm --version` and `node --version`
- Relevant code snippet
- Screenshots if applicable

---

## Common Quick Fixes

| Problem | Quick Fix |
|---------|-----------|
| Port in use | `npm run dev -- --port 3001` |
| Module not found | `npm install && npm run dev` |
| Database error | `psql $DATABASE_URL` (test connection) |
| Auth failing | Check `.env` values and restart |
| Prisma out of sync | `npx prisma generate` |
| Build too slow | Clear cache: `rm -rf .output` |
| Memory error | `NODE_OPTIONS=--max-old-space-size=4096` |

---

## Still Stuck?

1. Create issue on GitHub with details above
2. Check [SETUP.md](./SETUP.md) for setup steps
3. Review [ARCHITECTURE.md](./ARCHITECTURE.md) for system overview
4. Check [ENV.md](./ENV.md) for variable configuration
