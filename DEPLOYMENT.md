# Deployment Guide

## Deployment Options Comparison

| Platform | Cost | Ease | Scalability | Support |
|----------|------|------|-------------|---------|
| **Vercel** ⭐ | $0-100/mo | Very Easy | Excellent | Excellent |
| **Railway** | $5-100+/mo | Easy | Very Good | Good |
| **Render** | $0-500+/mo | Easy | Very Good | Good |
| **DigitalOcean** | $4-500+/mo | Medium | Excellent | Good |
| **AWS** | Varies | Hard | Excellent | Excellent |

**Recommendation for MVP**: **Vercel** (simplest) or **Railway** (best balance)

---

## Option 1: Vercel (Recommended for Startups)

### Advantages
✅ Auto-scaling  
✅ Zero-config deployment  
✅ Global CDN included  
✅ Free tier available  
✅ TanStack Start native support  

### Disadvantages
❌ Limited database on free tier  
❌ Serverless limitations  

### Setup Steps

#### 1. Prepare Code for Vercel

Update `vite.config.ts`:

```typescript
import { defineConfig } from 'vite'
import { tanstackStart } from '@tanstack/react-start/plugin/vite'

export default defineConfig({
  plugins: [tanstackStart()],
  ssr: {
    external: ['pg', '@prisma/client']
  }
})
```

#### 2. Configure Package.json

```json
{
  "engines": {
    "node": "18.x || 20.x"
  },
  "scripts": {
    "build": "vite build",
    "start": "node .output/server/index.mjs"
  }
}
```

#### 3. Create `vercel.json`

```json
{
  "buildCommand": "npm run build",
  "outputDirectory": ".output/public",
  "framework": "other",
  "nodeVersion": "20.x"
}
```

#### 4. Push to GitHub

```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/your-username/ppt-ai-builder.git
git push -u origin main
```

#### 5. Connect to Vercel

1. Go to [vercel.com](https://vercel.com)
2. Sign up / Log in
3. Click "New Project"
4. Import GitHub repository
5. Set environment variables (see below)
6. Deploy

#### 6. Add Environment Variables

In Vercel dashboard → Settings → Environment Variables:

```
DATABASE_URL=
BETTER_AUTH_SECRET=
BETTER_AUTH_URL=https://your-domain.vercel.app
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
GOOGLE_GENERATIVE_AI_API_KEY=
IMAGEKIT_PUBLIC_KEY=
IMAGEKIT_PRIVATE_KEY=
IMAGEKIT_URL_ENDPOINT=
IMAGEKIT_BASE_URL=
INNGEST_SIGNING_KEY=
INNGEST_EVENT_KEY=
```

#### 7. Database Setup

**Option A: Neon (PostgreSQL as a Service)**

1. Sign up at [neon.tech](https://neon.tech)
2. Create project
3. Copy connection string
4. Set `DATABASE_URL` in Vercel
5. Run migrations:

```bash
vercel env pull .env.production
npx prisma migrate deploy
```

**Option B: Supabase (PostgreSQL + Auth)**

1. Sign up at [supabase.com](https://supabase.com)
2. Create project
3. Get connection string from settings
4. Set `DATABASE_URL` in Vercel

#### 8. Deploy

```bash
# Via Vercel CLI
npm i -g vercel
vercel

# Or push to GitHub and auto-deploy
git push origin main
```

---

## Option 2: Railway

### Advantages
✅ Simple deployment  
✅ Free tier with GitHub link  
✅ Built-in database templates  
✅ Environment variable management  
✅ Good documentation  

### Setup Steps

#### 1. Create Railway Account

Go to [railway.app](https://railway.app) and sign up with GitHub

#### 2. Create New Project

- Click "New Project"
- Select "Deploy from GitHub repo"
- Choose your repository

#### 3. Configure Services

**Add PostgreSQL:**
- Click "Add Service"
- Search "PostgreSQL"
- Select and deploy

**Configure App Environment:**

```bash
# Railway generates these automatically
DATABASE_URL          # From PostgreSQL service
PORT=3000
NODE_ENV=production
```

#### 4. Set Environment Variables

In Railway → Variables:

```
BETTER_AUTH_SECRET=your-secret
BETTER_AUTH_URL=https://your-app.railway.app
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
GOOGLE_GENERATIVE_AI_API_KEY=
IMAGEKIT_PUBLIC_KEY=
IMAGEKIT_PRIVATE_KEY=
IMAGEKIT_URL_ENDPOINT=
IMAGEKIT_BASE_URL=
```

#### 5. Configure Start Command

In Railway → Settings → Deployment:

```
Build Command: npm run build
Start Command: npm start
```

#### 6. Deploy

```bash
# Via Railway CLI
npm i -g railway
railway link
railway up

# Or just push to GitHub
git push origin main
```

---

## Option 3: DigitalOcean App Platform

### Setup Steps

#### 1. Create DigitalOcean Account

Sign up at [digitalocean.com](https://www.digitalocean.com)

#### 2. Create App

- Click "Create" → "Apps"
- Select GitHub repo
- Choose branch to deploy

#### 3. Configure Resources

**App Service:**
- Name: `ppt-ai`
- HTTP Port: 3000
- Build command: `npm run build`
- Run command: `npm start`

**Database:**
- Create managed PostgreSQL
- Note the connection string

#### 4. Environment Variables

Add all required vars in App Platform

#### 5. Deploy

Click "Deploy App"

---

## Option 4: AWS Elastic Container Service (ECS)

### Setup Steps

#### 1. Create Docker Image

Create `Dockerfile`:

```dockerfile
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .
RUN npm run build

EXPOSE 3000

CMD ["npm", "start"]
```

Create `.dockerignore`:

```
node_modules
.git
.env
.env.local
dist
.output
```

#### 2. Build & Push to ECR

```bash
# Create ECR repository
aws ecr create-repository --repository-name ppt-ai

# Build image
docker build -t ppt-ai:latest .

# Tag image
docker tag ppt-ai:latest <account-id>.dkr.ecr.<region>.amazonaws.com/ppt-ai:latest

# Push to ECR
aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <account-id>.dkr.ecr.<region>.amazonaws.com
docker push <account-id>.dkr.ecr.<region>.amazonaws.com/ppt-ai:latest
```

#### 3. Create RDS PostgreSQL

- Use AWS RDS service
- Create PostgreSQL database
- Get endpoint and credentials

#### 4. Create ECS Cluster

- Create cluster
- Create task definition with Docker image
- Create service with load balancer

#### 5. Environment Variables

Set in ECS task definition environment section

---

## Pre-Deployment Checklist

### Code Quality
- [ ] Run `npm run lint` - no errors
- [ ] Run `npm run build` - builds successfully
- [ ] TypeScript compiles: `npx tsc --noEmit`
- [ ] All tests pass: `npm run test`

### Environment
- [ ] All required environment variables documented
- [ ] Database connection tested locally
- [ ] OAuth credentials working
- [ ] ImageKit account verified
- [ ] Inngest account connected

### Security
- [ ] No secrets in code
- [ ] Environment variables are sensitive
- [ ] HTTPS enabled
- [ ] CORS configured correctly
- [ ] Rate limiting considered

### Database
- [ ] Migrations created
- [ ] Schema reviewed
- [ ] Indexes added for performance
- [ ] Backups configured

### Monitoring
- [ ] Error tracking set up (Sentry, LogRocket)
- [ ] Performance monitoring enabled
- [ ] Logs are being collected

---

## Post-Deployment Checklist

### Verification
- [ ] Website loads without errors
- [ ] Can login with Google/GitHub
- [ ] Can generate presentation
- [ ] Can download PPTX
- [ ] Database operations working

### Performance
- [ ] Check response times
- [ ] Monitor error rates
- [ ] Check database performance
- [ ] Monitor costs

### Security
- [ ] SSL certificate valid
- [ ] Headers configured
- [ ] No sensitive data in logs
- [ ] Rate limiting working

### Monitoring
- [ ] Alerts configured
- [ ] Uptime monitoring enabled
- [ ] Performance thresholds set

---

## Domain & SSL Setup

### Add Custom Domain

**Vercel:**
1. Settings → Domains
2. Add domain
3. Update DNS records
4. SSL auto-provisioned

**Railway/DigitalOcean:**
1. Add domain in settings
2. Update DNS to point to service
3. SSL provisioned automatically

### DNS Configuration

Update your domain registrar:

```
CNAME record:
Name: www
Value: your-app.vercel.app (or Railway/DigitalOcean equivalent)

A record:
Name: @
Value: IP address provided by platform
```

---

## Database Backups

### Automated Backups

**Neon:**
- Automatic daily backups
- 7-day retention free tier

**Supabase:**
- Daily backups included
- Point-in-time recovery available

**AWS RDS:**
- Automated backups
- Configurable retention period

### Manual Backup

```bash
# Backup database
pg_dump $DATABASE_URL > backup.sql

# Restore
psql $DATABASE_URL < backup.sql
```

---

## Troubleshooting Deployment

### Build Fails

```bash
# Clear cache
rm -rf node_modules .nuxt .output
npm install
npm run build
```

### Database Connection Error

```bash
# Test connection string
psql $DATABASE_URL

# Run migrations
npx prisma migrate deploy
```

### Environment Variables Not Working

- Verify variable names match
- Check for typos
- Restart application after changing
- Use `vercel env pull` to verify locally

### Application Crashes

Check logs:
- Vercel: Deployments → Logs
- Railway: Deployments → Logs
- DigitalOcean: View Logs

---

## Scaling

### When to Scale

- Response time > 2 seconds
- Error rate > 1%
- CPU usage > 80%
- Database connections at limit

### Scaling Strategies

1. **Increase Resources**: Upgrade server tier
2. **Add Caching**: Redis for frequent queries
3. **Database Optimization**: Add indexes, optimize queries
4. **Load Balancing**: Multiple app instances
5. **CDN**: Cache static assets

---

## Costs Estimation

### Typical Monthly Costs

| Service | Estimate |
|---------|----------|
| App Hosting | $10-50 |
| Database | $10-30 |
| ImageKit | $5-30 |
| Google AI | $0-20 |
| CDN | $0-10 |
| **Total** | **$25-140** |

Varies based on usage and selected tier.

---

## Next Steps

1. Choose deployment platform
2. Complete pre-deployment checklist
3. Deploy following selected option
4. Set up monitoring
5. Configure custom domain
6. Enable automated backups
7. Set up CI/CD if not included

**Questions?** See [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
