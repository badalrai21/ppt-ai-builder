# Architecture & System Design

## System Overview

PPT.ai is a full-stack web application that generates presentations using AI. It combines frontend and backend components for a seamless experience.

```
┌─────────────────────────────────────────────────────────┐
│                   User Browser                           │
│  ┌──────────────────────────────────────────────────┐   │
│  │  React 19 Frontend (SPA)                         │   │
│  │  - TanStack Router for routing                   │   │
│  │  - TanStack Query for data fetching              │   │
│  │  - TailwindCSS for styling                       │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
                        ↓ HTTP/WS
┌─────────────────────────────────────────────────────────┐
│              TanStack Start Backend (Nitro)              │
│  ┌──────────────────────────────────────────────────┐   │
│  │  API Routes & Server Functions                   │   │
│  │  - Authentication endpoints                      │   │
│  │  - Presentation CRUD operations                  │   │
│  │  - File export functionality                     │   │
│  └──────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Middleware                                      │   │
│  │  - Session authentication                        │   │
│  │  - Request logging                               │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
        ↓                    ↓                    ↓
    ┌────────┐          ┌────────┐          ┌──────────┐
    │ Prisma │          │ Inngest│          │ Google   │
    │  ORM   │          │ Tasks  │          │ Gemini   │
    └────────┘          └────────┘          └──────────┘
        ↓                    ↓                    ↓
    ┌────────┐          ┌────────┐          ┌──────────┐
    │ PostgreSQL       │ Job    │          │ AI       │
    │ Database │       │ Queue  │          │ API      │
    └────────┘          └────────┘          └──────────┘
```

## Technology Stack

### Frontend
- **React 19** - UI framework
- **TypeScript** - Type safety
- **TanStack Router** - Client-side routing
- **TanStack Query** - Server state management
- **TailwindCSS** - Utility-first CSS
- **shadcn/ui** - Component library
- **Radix UI** - Accessible components

### Backend
- **Nitro** - Node.js server framework
- **TanStack Start** - Full-stack meta-framework
- **TypeScript** - Type safety
- **Zod** - Schema validation

### Database
- **PostgreSQL** - Primary database
- **Prisma** - ORM and schema management
- **Database Adapters** - PostgreSQL adapter

### Authentication
- **Better Auth** - Authentication library
- **Google OAuth 2.0** - Google sign-in
- **GitHub OAuth** - GitHub sign-in
- **Session-based auth** - Secure sessions

### AI & External Services
- **Google Generative AI** - Gemini for content generation
- **ImageKit** - Image hosting and optimization
- **Inngest** - Serverless job queue

### DevTools
- **Vite** - Build tool
- **ESLint** - Code linting
- **Prettier** - Code formatting
- **TypeScript** - Type checking

## Data Flow

### Presentation Generation Flow

```
1. User Input
   └─ Fills form with topic, style, tone, layout, slide count

2. Frontend Submission
   └─ Calls createPresentation() server function
   └─ Validation with Zod schema

3. Backend Processing
   └─ Authenticate user
   └─ Create presentation record in database
   └─ Trigger Inngest job for async generation
   └─ Return presentation ID to frontend

4. Background Job (Inngest)
   └─ Fetch presentation from database
   └─ Call Google Gemini API
   └─ Parse slide content and structure
   └─ Create slides in database
   └─ Update presentation status to COMPLETED

5. Frontend Updates
   └─ Poll database for presentation status
   └─ Update UI as slides become available
   └─ Display presentation for user

6. Export
   └─ User downloads as PPTX
   └─ pptxgenjs generates PowerPoint file
   └─ Browser initiates download
```

## Component Architecture

### Feature-Based Structure

Each major feature (like "presentations") follows this structure:

```
features/presentations/
├── components/          # React components
│   ├── presentation-card.tsx
│   ├── slide-preview.tsx
│   └── slideshow-modal.tsx
├── hooks/              # Custom React hooks
│   ├── use-presentation-detail.ts
│   └── use-fullscreen.ts
├── actions/            # Server functions
│   └── presentation-mutations.ts
├── api/                # Query functions
│   └── presentation-queries.ts
├── types/              # TypeScript types
│   ├── presentation.types.ts
│   └── schemas.ts
├── lib/                # Utilities
│   ├── export-pptx.ts
│   └── server-helpers.ts
├── constants/          # Constants
│   ├── presentation-options.ts
│   └── presentation-templates.ts
└── index.ts            # Barrel export
```

### Route Structure

```
routes/
├── __root.tsx          # Root layout
├── index.tsx           # Home page (protected)
├── _auth/
│   ├── route.tsx       # Auth layout
│   ├── login.tsx       # Login page
│   └── signup.tsx      # Sign-up page
├── presentations/
│   ├── $presentationId.tsx  # Presentation detail
│   └── $presentationId/
│       └── edit.tsx    # Edit presentation
└── api/
    ├── auth/
    │   └── $.ts        # Auth endpoints
    └── inngest.ts      # Inngest webhook
```

## Database Schema

### Core Tables

**users**
```
- id (primary key)
- email (unique)
- name
- image (avatar)
- createdAt
- updatedAt
```

**presentations**
```
- id (primary key)
- userId (foreign key → users)
- title
- prompt (user's original prompt)
- status (GENERATING, COMPLETED, FAILED)
- slideCount
- style (minimal, professional, bold, creative)
- tone (formal, informative, persuasive)
- layout (balanced, visual, bullet-points)
- createdAt
- updatedAt
```

**slides**
```
- id (primary key)
- presentationId (foreign key → presentations)
- order (slide number)
- title
- content
- notes (speaker notes)
- imagePrompt
- imageUrl
- createdAt
```

**sessions** (Better Auth)
```
- sessionToken (primary key)
- userId
- expires
```

**accounts** (Better Auth)
```
- userId (foreign key → users)
- provider (google, github)
- providerAccountId
```

## Authentication Flow

```
1. User visits app
   └─ Check session cookie
   
2. If no session
   └─ Redirect to /login
   └─ Show Google/GitHub OAuth buttons
   
3. User clicks OAuth provider
   └─ Redirected to OAuth provider
   └─ User authorizes app
   └─ Redirected back with auth code
   
4. Backend exchanges code for token
   └─ Create user if new
   └─ Create session
   └─ Set secure session cookie
   
5. Redirect to dashboard
   └─ Session verified on every request
   └─ User context available in components
```

## Performance Considerations

### Frontend Optimization
- **Code splitting** - Routes lazy-loaded
- **React Query caching** - Reduce API calls
- **Image optimization** - ImageKit compression
- **Memoization** - React.memo for expensive components

### Backend Optimization
- **Database indexing** - Fast queries
- **Query optimization** - Select only needed fields
- **Caching** - Session caching
- **Async processing** - Inngest for heavy tasks

### Database Optimization
- Indexes on frequently queried columns
- Foreign key constraints for referential integrity
- Connection pooling with PostgreSQL adapter

## Security Architecture

### Authentication & Authorization
- OAuth 2.0 for secure authentication
- Session-based access control
- Middleware to verify sessions
- Protected API routes

### Data Protection
- Prisma ORM prevents SQL injection
- Input validation with Zod
- HTTPS/TLS for data in transit
- Environment variables for secrets

### API Security
- CORS configuration
- Rate limiting (configurable)
- Request validation
- Error handling without exposing internals

## Deployment Architecture

### Production Setup

```
┌──────────────────────────────────────┐
│     CDN / Edge Network               │
│     (Assets, caching)                │
└──────────────────────────────────────┘
            ↓
┌──────────────────────────────────────┐
│     Application Server               │
│     (Nitro)                          │
│     - Auto-scaling                   │
│     - Load balancing                 │
└──────────────────────────────────────┘
            ↓
┌──────────────────────────────────────┐
│     Managed Database                 │
│     (PostgreSQL)                     │
│     - Replication                    │
│     - Backups                        │
└──────────────────────────────────────┘
```

### External Services
- **ImageKit** - Image hosting
- **Google Cloud** - AI/ML services
- **Inngest** - Background jobs
- **OAuth Providers** - Auth services

## Monitoring & Observability

Key metrics to monitor:
- Application error rates
- API response times
- Database query performance
- Background job success rate
- User session duration
- Presentation generation time

## Scalability

### Current Architecture Supports
- Thousands of concurrent users
- Millions of presentations
- Real-time notifications with WebSockets
- Background job processing

### Scaling Strategies
- Horizontal scaling with load balancers
- Database read replicas
- Caching layer (Redis)
- CDN for static assets
- Microservices if needed

## Future Architecture Improvements
- [ ] Real-time collaboration (WebSockets)
- [ ] Message queue for better job management
- [ ] Caching layer (Redis)
- [ ] API rate limiting
- [ ] Analytics pipeline
- [ ] Monitoring system
