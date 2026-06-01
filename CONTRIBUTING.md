# Contributing Guidelines

Thank you for your interest in contributing to PPT.ai! This document provides guidelines for contributing to the project.

## Getting Started

### Prerequisites

- Node.js 18+
- Git
- PostgreSQL (local development)

### Development Setup

```bash
# 1. Fork and clone repository
git clone https://github.com/YOUR-USERNAME/ppt-ai-builder.git
cd ppt-ai-builder

# 2. Create feature branch
git checkout -b feature/your-feature-name

# 3. Install dependencies
npm install

# 4. Configure environment (see SETUP.md)
cp .env.example .env
# Edit .env with your credentials

# 5. Start development server
npm run dev
```

## Code Style & Standards

### TypeScript

- Use strict mode (enabled in `tsconfig.json`)
- Provide explicit return types
- Avoid `any` type
- Use proper type narrowing

```typescript
// ✅ Good
function processData(data: unknown): string {
  if (typeof data === 'string') {
    return data.toUpperCase()
  }
  throw new Error('Expected string')
}

// ❌ Avoid
function processData(data: any) {
  return data.toUpperCase()
}
```

### React & Components

```typescript
// ✅ Use functional components
export function MyComponent() {
  return <div>Content</div>
}

// ✅ Use const over function
const MyComponent = () => {
  return <div>Content</div>
}

// ❌ Avoid class components
class MyComponent extends React.Component {
  render() { /* ... */ }
}
```

### Naming Conventions

- **Files**: kebab-case for most files
  ```
  my-component.tsx
  use-presentation.ts
  ```

- **Directories**: kebab-case
  ```
  components/
  features/presentations/
  ```

- **Constants**: UPPER_SNAKE_CASE
  ```typescript
  const MAX_SLIDES = 20
  const SLIDE_STYLES = ['minimal', 'professional']
  ```

- **Variables/Functions**: camelCase
  ```typescript
  const userName = 'John'
  function getUserName() { /* */ }
  ```

- **Components**: PascalCase
  ```typescript
  function PresentationCard() { /* */ }
  ```

## Code Quality

### Before Committing

```bash
# Check formatting
npm run check

# Fix formatting
npm run format

# Check linting
npm run lint

# Run type checking
npx tsc --noEmit

# Run tests (if applicable)
npm run test
```

### Linting Rules

Our ESLint config enforces:
- No unused variables
- Consistent imports
- React best practices
- TypeScript strict mode

### Comments

- Use comments for WHY, not WHAT
- Keep comments up-to-date with code
- Avoid obvious comments

```typescript
// ✅ Good
// Debounce user input to avoid excessive API calls
const debouncedSearch = useMemo(
  () => debounce(search, 500),
  []
)

// ❌ Avoid
// Set the name
const name = 'John'
```

## Git Workflow

### Branch Naming

```
feature/add-user-auth
fix/login-redirect-bug
docs/add-deployment-guide
chore/update-dependencies
```

### Commit Messages

Format: `type: brief description`

```
feat: add presentation export to PDF
fix: resolve authentication session timeout
docs: update database schema documentation
chore: update dependencies
refactor: simplify slide rendering logic
test: add tests for presentation generation
```

**Types:**
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation
- `chore` - Maintenance
- `refactor` - Code refactoring
- `test` - Add/update tests
- `style` - Code style (formatting, semicolons, etc.)
- `perf` - Performance improvement

### Good Commit Practices

✅ **Do:**
- Commit frequently
- Use meaningful messages
- Reference issues in commits
- Test before committing

❌ **Don't:**
- Mix unrelated changes
- Commit broken code
- Use vague messages like "fix stuff"
- Commit sensitive data

```bash
# Good commit
git commit -m "feat: add slide regeneration

- Allow users to regenerate individual slides
- Add regenerate button to slide preview
- Show loading state during regeneration
- Fixes #123"
```

## Feature Development

### Step 1: Check Issue / Create Issue

- Check open issues first
- Create issue describing feature
- Get feedback before implementing

### Step 2: Create Branch

```bash
git checkout -b feature/my-feature
```

### Step 3: Implement Feature

- Follow code style guidelines
- Write clear code
- Add comments for complex logic
- Test frequently

### Step 4: Test Locally

```bash
npm run dev
# Test feature manually

npm run lint
npm run format
npm run test
```

### Step 5: Commit Changes

```bash
git add .
git commit -m "feat: describe your feature"
```

### Step 6: Create Pull Request

- Push to your fork
- Create PR with clear description
- Reference related issues
- Add screenshots if UI changes

```markdown
## Description
Brief description of changes

## Related Issues
Fixes #123

## Testing
Steps to verify the changes

## Screenshots (if UI changes)
[Add screenshots here]
```

## Pull Request Process

### Before Submitting

- [ ] Code follows style guidelines
- [ ] All tests pass
- [ ] Documentation updated if needed
- [ ] No breaking changes (or well-documented)
- [ ] Commits have clear messages

### Review Process

1. **Automated Checks**
   - Linting passes
   - TypeScript compiles
   - Tests pass

2. **Code Review**
   - Reviewers check logic
   - Ensure consistency
   - Validate approach

3. **Merge**
   - Use "Squash and merge" for feature branches
   - Use "Create merge commit" for release branches

### Addressing Review Comments

- Respond to all comments
- Make requested changes
- Push new commits (don't rebase)
- Request re-review if needed

## Documentation

### When to Document

- ✅ New features
- ✅ API changes
- ✅ Complex logic
- ✅ Architecture decisions

### What to Document

- High-level overview
- API/function signatures
- Usage examples
- Edge cases and limitations

### Documentation Files

Update relevant docs:
- `README.md` - High-level overview
- `SETUP.md` - Setup/installation
- `ARCHITECTURE.md` - System design
- `API.md` - API endpoints
- `ENV.md` - Environment variables
- `TROUBLESHOOTING.md` - Common issues

## Testing

### Current State

- Basic unit tests available
- Integration testing recommended
- E2E testing planned

### Adding Tests

```typescript
// Example test
import { expect, test } from 'vitest'
import { generateTitle } from './presentation-utils'

test('generateTitle creates valid title', () => {
  const title = generateTitle('AI and ML')
  expect(title).toBeTruthy()
  expect(title).toContain('AI')
})
```

Run tests:

```bash
npm run test          # Run once
npm run test:watch   # Watch mode
```

## Security

### Do's ✅

- Validate user input
- Use environment variables for secrets
- Follow OWASP guidelines
- Report security issues privately

### Don'ts ❌

- Never commit API keys
- Don't expose secrets in error messages
- Don't trust user input
- Don't use eval or similar

### Reporting Security Issues

**Do NOT** create public GitHub issues for security vulnerabilities.

Instead:
1. Email security details to maintainers
2. Provide clear description
3. Include reproduction steps
4. Allow time for fix before disclosure

## Performance

### Guidelines

- Measure before optimizing
- Use React DevTools Profiler
- Avoid unnecessary re-renders
- Optimize database queries
- Use React Query caching

### Common Optimizations

```typescript
// Memoize expensive components
const MemoizedComponent = React.memo(ExpensiveComponent)

// Memoize callbacks
const memoizedCallback = useCallback(() => {
  // ...
}, [dependencies])

// Memoize computations
const memoizedValue = useMemo(() => {
  return expensiveCalculation()
}, [dependencies])
```

## Accessibility

### Guidelines

- Use semantic HTML
- Include alt text for images
- Ensure keyboard navigation
- Maintain sufficient color contrast
- Use ARIA labels where needed

```typescript
// Good accessibility
<button 
  aria-label="Generate presentation"
  onClick={handleGenerate}
>
  <Wand2 />
</button>

// With proper heading hierarchy
<h1>Presentations</h1>
<h2>Recent</h2>
```

## Release Process

### Version Numbers

Use semantic versioning: `MAJOR.MINOR.PATCH`

- `1.0.0` - Initial release
- `1.1.0` - New features (backwards compatible)
- `1.1.1` - Bug fixes
- `2.0.0` - Breaking changes

### Release Checklist

- [ ] All tests pass
- [ ] Update version in package.json
- [ ] Update CHANGELOG.md
- [ ] Create release tag
- [ ] Deploy to production
- [ ] Publish release notes

## Community

### Be Respectful

- Treat everyone with respect
- No discrimination or harassment
- Welcome diverse perspectives
- Help newcomers

### Code of Conduct

We follow a Code of Conduct. Report violations to maintainers.

## Questions?

- Check documentation files
- Search existing issues/discussions
- Ask in GitHub Discussions
- Email maintainers

## Thank You!

Thank you for contributing to PPT.ai! Your efforts help make this project better for everyone.

---

## Useful Links

- [GitHub Repository](https://github.com/your-org/ppt-ai-builder)
- [Issues](https://github.com/your-org/ppt-ai-builder/issues)
- [Discussions](https://github.com/your-org/ppt-ai-builder/discussions)
- [Documentation](./README.md)
- [Setup Guide](./SETUP.md)
- [Code of Conduct](./CODE_OF_CONDUCT.md) (if exists)
