# API & Server Functions Reference

## Overview

PPT.ai uses TanStack Start's server functions for API calls. All functions are type-safe and handle validation automatically.

## Server Functions

### Presentation Functions

#### `createPresentation`

Generate a new presentation from a prompt.

**Endpoint:** `POST /api/presentations`

**Input:**
```typescript
{
  prompt: string          // Presentation topic (required)
  slideCount: number      // Number of slides (3-20)
  style: SlideStyle       // 'minimal' | 'professional' | 'bold' | 'creative'
  tone: SlideTone         // 'formal' | 'informative' | 'persuasive'
  layout: SlideLayout     // 'balanced' | 'visual' | 'bullet-points'
}
```

**Output:**
```typescript
{
  id: string
  userId: string
  title: string
  prompt: string
  status: 'GENERATING' | 'COMPLETED' | 'FAILED'
  slideCount: number
  style: SlideStyle
  tone: SlideTone
  layout: SlideLayout
  createdAt: Date
  updatedAt: Date
}
```

**Example:**
```typescript
const presentation = await createPresentation({
  data: {
    prompt: "AI and Machine Learning in 2024",
    slideCount: 8,
    style: 'professional',
    tone: 'informative',
    layout: 'balanced'
  }
})
```

**Status Codes:**
- `200` - Success, presentation created
- `401` - Unauthorized (not logged in)
- `400` - Invalid input
- `500` - Server error

---

#### `updatePresentation`

Update presentation settings (doesn't regenerate).

**Endpoint:** `POST /api/presentations/:id`

**Input:**
```typescript
{
  id: string                           // Presentation ID
  title?: string
  prompt?: string
  slideCount?: number
  style?: SlideStyle
  tone?: SlideTone
  layout?: SlideLayout
}
```

**Output:** Updated presentation object

**Example:**
```typescript
await updatePresentation({
  data: {
    id: "pres-123",
    title: "New Title"
  }
})
```

---

#### `deletePresentation`

Delete a presentation and all its slides.

**Endpoint:** `DELETE /api/presentations/:id`

**Input:**
```typescript
{
  id: string  // Presentation ID
}
```

**Output:**
```typescript
{
  ok: true
}
```

**Example:**
```typescript
await deletePresentation({
  data: { id: "pres-123" }
})
```

---

#### `regeneratePresentation`

Regenerate slides for an existing presentation.

**Endpoint:** `POST /api/presentations/:id/regenerate`

**Input:**
```typescript
{
  id: string  // Presentation ID
}
```

**Output:**
```typescript
{
  ok: true
}
```

**Example:**
```typescript
await regeneratePresentation({
  data: { id: "pres-123" }
})
```

---

### Query Functions

#### `listPresentations`

Get all presentations for logged-in user.

**Endpoint:** `GET /api/presentations`

**Input:** None

**Output:**
```typescript
Array<{
  id: string
  title: string
  prompt: string
  status: string
  slideCount: number
  createdAt: Date
  updatedAt: Date
  _count: {
    slides: number
  }
}>
```

**Example:**
```typescript
const presentations = await listPresentations()
```

---

#### `getPresentationWithSlides`

Get a specific presentation with all its slides.

**Endpoint:** `GET /api/presentations/:id`

**Input:**
```typescript
{
  id: string  // Presentation ID
}
```

**Output:**
```typescript
{
  id: string
  title: string
  prompt: string
  status: string
  slideCount: number
  slides: Array<{
    id: string
    order: number
    title: string
    content: string
    notes: string | null
    imagePrompt: string
    imageUrl: string | null
  }>
}
```

**Example:**
```typescript
const presentation = await getPresentationWithSlides({
  data: { id: "pres-123" }
})
```

---

## Authentication Endpoints

### OAuth Callback

**Endpoint:** `GET /api/auth/callback/:provider`

Handles OAuth provider callbacks.

**Providers:** `google`, `github`

**Automatic redirects to dashboard after auth**

---

### Session Endpoint

**Endpoint:** `GET /api/auth/session`

Get current user session.

**Output:**
```typescript
{
  user: {
    id: string
    email: string
    name: string
    image: string | null
  }
  expires: Date
} | null
```

---

## Background Jobs (Inngest)

### Presentation Generation Job

**Event:** `presentation/generate`

Triggered automatically after presentation creation.

**Data:**
```typescript
{
  presentationId: string
}
```

**Flow:**
1. Fetch presentation from DB
2. Mark as GENERATING
3. Call Google Gemini API
4. Generate slides
5. Store in database
6. Mark as COMPLETED

**Webhook:** `POST /api/inngest`

---

## Using Server Functions in Components

### React Query Hook Pattern

```typescript
import { useQuery } from '@tanstack/react-query'
import { listPresentations, presentationQueryKeys } from '#/features/presentations'

export function PresentationList() {
  const { data: presentations, isLoading } = useQuery({
    queryKey: presentationQueryKeys.list(),
    queryFn: () => listPresentations(),
  })

  if (isLoading) return <div>Loading...</div>

  return (
    <div>
      {presentations?.map(p => (
        <div key={p.id}>{p.title}</div>
      ))}
    </div>
  )
}
```

### Mutation Pattern

```typescript
import { useMutation, useQueryClient } from '@tanstack/react-query'
import { createPresentation, presentationQueryKeys } from '#/features/presentations'

export function CreatePresentationForm() {
  const queryClient = useQueryClient()
  
  const mutation = useMutation({
    mutationFn: (data) => createPresentation({ data }),
    onSuccess: () => {
      queryClient.invalidateQueries({
        queryKey: presentationQueryKeys.list()
      })
    }
  })

  return (
    <button onClick={() => mutation.mutate({...formData})}>
      Create
    </button>
  )
}
```

---

## Error Handling

### Client-Side Error Handling

```typescript
try {
  const result = await createPresentation({ data })
} catch (error) {
  if (error instanceof Error) {
    console.error(error.message)
    // Show error toast to user
  }
}
```

### Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| "Not found" | Presentation doesn't exist | Check ID in URL |
| "Unauthorized" | Not logged in | Redirect to login |
| "Invalid input" | Schema validation failed | Check form data |
| "AI API error" | Gemini API failed | Retry or check quota |
| "Database error" | DB connection issue | Check DATABASE_URL |

---

## Rate Limiting

Currently no rate limiting implemented. Add for production:

```typescript
import { Ratelimit } from '@upstash/ratelimit'

const ratelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(10, '1 h'),
})

// In server function
const { success } = await ratelimit.limit(userId)
if (!success) throw new Error('Rate limit exceeded')
```

---

## Testing API Functions

### Local Testing

```bash
# Start dev server
npm run dev

# In browser console
const response = await fetch('/api/presentations', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    prompt: 'Test',
    slideCount: 5,
    style: 'minimal',
    tone: 'formal',
    layout: 'balanced'
  })
})
const data = await response.json()
console.log(data)
```

---

## API Versioning

Current API version: `v1` (implicit)

For future versions, consider:
- URL prefix: `/api/v2/presentations`
- Header: `Accept: application/vnd.api+v2+json`

---

## Deprecation Policy

Breaking changes require:
1. 30-day notice
2. Backwards compatibility layer
3. Migration guide
4. Deprecation warnings in logs

---

## Documentation

For more details see:
- [ARCHITECTURE.md](./ARCHITECTURE.md) - System design
- [SETUP.md](./SETUP.md) - Development setup
- [ENV.md](./ENV.md) - Environment variables
