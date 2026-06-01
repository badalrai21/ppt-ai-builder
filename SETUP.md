# Setup & Development Guide

## Prerequisites

- **Node.js** 18.0.0 or higher
- **npm** 9.0.0 or higher (or pnpm/yarn)
- **PostgreSQL** 14+ (local or remote)
- **Git** for version control

### Required Accounts & Credentials

1. **Google Cloud Project**
   - Google OAuth credentials
   - Generative AI API key (Gemini)

2. **GitHub**
   - OAuth application (optional, for authentication)

3. **ImageKit**
   - Account for image hosting

4. **Inngest**
   - Account for background job queue

## Local Development Setup

### 1. Clone Repository

```bash
git clone <repository-url>
cd ppt-ai-builder
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Database Setup

Create PostgreSQL database:

```bash
# Using psql
createdb ppt_ai_db

# Or use your preferred database client
```

### 4. Environment Variables

Create `.env` file in root directory:

```bash
# Database
DATABASE_URL="postgresql://user:password@localhost:5432/ppt_ai_db?schema=public"

# Authentication
BETTER_AUTH_SECRET="generate-a-random-secret-key"
BETTER_AUTH_URL="http://localhost:3000"

# Google OAuth
GOOGLE_CLIENT_ID="your-client-id.apps.googleusercontent.com"
GOOGLE_CLIENT_SECRET="your-client-secret"

# Google Generative AI
GOOGLE_GENERATIVE_AI_API_KEY="your-gemini-api-key"

# GitHub OAuth (Optional)
GITHUB_CLIENT_ID="your-github-client-id"
GITHUB_CLIENT_SECRET="your-github-client-secret"

# ImageKit
IMAGEKIT_PUBLIC_KEY="your-public-key"
IMAGEKIT_PRIVATE_KEY="your-private-key"
IMAGEKIT_URL_ENDPOINT="https://ik.imagekit.io/your-id"
IMAGEKIT_BASE_URL="https://ik.imagekit.io/your-id"

# Inngest
INNGEST_DEV="1"
```

### 5. Database Migrations

```bash
# Run migrations
npx prisma migrate dev

# Generate Prisma client
npx prisma generate

# Open Prisma Studio (optional, for data management)
npx prisma studio
```

### 6. Start Development Server

```bash
npm run dev
```

Server runs on `http://localhost:3000`

## Development Workflow

### Available Commands

```bash
# Development
npm run dev              # Start dev server with hot reload
npm run dev:open        # Start dev server and open browser

# Building
npm run build           # Production build
npm run preview         # Preview production build locally

# Code Quality
npm run lint            # Run ESLint
npm run format          # Format code with Prettier
npm run check           # Check formatting without changes
npm run format:fix      # Auto-fix formatting issues

# Database
npx prisma migrate dev  # Create and apply migrations
npx prisma migrate reset # Reset database (development only)
npx prisma studio      # Open visual database browser

# Testing
npm run test            # Run tests
npm run test:watch     # Run tests in watch mode
```

### Project Structure

```
src/
├── routes/                    # Page routes (TanStack Router)
│   ├── __root.tsx            # Root layout
│   ├── index.tsx             # Home page
│   ├── login.tsx             # Login page
│   ├── presentations.$id.tsx # Presentation detail
│   └── api/                  # API routes
├── components/               # Reusable React components
│   ├── ui/                   # UI primitives (shadcn/ui)
│   ├── navbar.tsx            # Navigation bar
│   ├── auth/                 # Auth related components
│   └── ...
├── features/                 # Feature modules
│   └── presentations/        # Presentation feature
│       ├── components/       # Feature components
│       ├── hooks/           # Feature hooks
│       ├── actions/         # Server actions
│       ├── api/             # API queries
│       ├── types/           # TypeScript types
│       ├── lib/             # Utilities
│       └── constants/       # Constants & templates
├── lib/                      # Core libraries
│   ├── auth.ts              # Auth utilities
│   ├── db.ts                # Database client
│   ├── imagekit.ts          # ImageKit integration
│   └── utils.ts             # Helper functions
├── middleware/               # Request middleware
├── integrations/            # External service integrations
│   ├── inngest/            # Background jobs
│   ├── better-auth/        # Authentication
│   └── tanstack-query/     # Data fetching
├── providers/              # React context providers
├── styles/                 # Global CSS
└── types/                  # Global types

```

### Important Files

- `vite.config.ts` - Vite & build configuration
- `tsconfig.json` - TypeScript configuration
- `eslint.config.js` - ESLint rules
- `prettier.config.js` - Prettier formatting rules
- `prisma/schema.prisma` - Database schema
- `package.json` - Dependencies and scripts

## Database Schema

Main tables:

- **User** - User accounts (from Better Auth)
- **Presentation** - Generated presentations
- **Slide** - Individual slides in presentations
- **Account** - OAuth account links
- **Session** - Active user sessions

See `prisma/schema.prisma` for full schema.

## Working with Prisma

### Generate Migrations

```bash
# After schema changes
npx prisma migrate dev --name add_feature_name
```

### View Database

```bash
# Open Prisma Studio GUI
npx prisma studio
```

### Reset Database (Dev Only)

```bash
npx prisma migrate reset
```

## Common Development Tasks

### Adding a New Route

1. Create file in `src/routes/` with route pattern
2. Export `Route` with `createFileRoute`
3. Implement component
4. Router auto-generates routes

### Adding a New Server Function

1. Create in `src/features/[feature]/actions/`
2. Use `createServerFn` from TanStack Start
3. Add input validation with Zod
4. Call from client using mutation

### Adding Database Query

1. Create in `src/features/[feature]/api/`
2. Use Prisma client
3. Create React Query hook wrapper
4. Use in components with `useQuery`

### Styling Components

Use TailwindCSS classes:

```tsx
<div className="flex items-center justify-between p-4 bg-background rounded-lg border border-border">
  <span className="text-sm font-medium">Label</span>
</div>
```

Available color tokens in `tailwind.config.ts`

## Debugging

### Browser DevTools

- React DevTools extension
- TanStack Router DevTools
- TanStack Query DevTools (in-app)

### Environment Logging

Add to `.env`:

```
DEBUG=*
```

### Prisma Logging

Enable in `prisma/schema.prisma`:

```prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
  logging  = ["query", "info", "warn", "error"]
}
```

## Troubleshooting

### Database Connection Issues

```bash
# Test connection
npx prisma db push --skip-generate

# Check DATABASE_URL format
echo $DATABASE_URL
```

### Build Errors

```bash
# Clear cache and reinstall
rm -rf node_modules .nuxt
npm install
npm run build
```

### Port Already in Use

```bash
# Use different port
npm run dev -- --port 3001
```

## Performance Tips

1. Use React Query for caching
2. Implement pagination for large lists
3. Lazy load routes
4. Optimize images with ImageKit
5. Use React.memo for expensive components
6. Profile with React DevTools Profiler

## Testing

### Setting Up Tests

```bash
# Run test suite
npm run test

# Watch mode
npm run test:watch

# Coverage
npm run test:coverage
```

## Next Steps

- Review [ARCHITECTURE.md](./ARCHITECTURE.md) for system design
- Check [API.md](./API.md) for available endpoints
- See [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) for common issues
- Read [ENV.md](./ENV.md) for environment variables
