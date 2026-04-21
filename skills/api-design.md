# Skill: api-design

> REST/GraphQL API design guidance — endpoint structure, versioning,
> error responses, pagination, and rate limiting patterns.
> Inspired by: claude-workflow-v2 (designing-apis)

## When to Trigger

- User says "design API", "API endpoints", "REST design", "GraphQL schema"
- Building a new service or microservice
- Reviewing or extending an existing API surface
- When inconsistent API patterns are detected

## Workflow

### Step 1 — Understand the Domain

1. Identify the domain entities (User, Order, Product, etc.)
2. Map relationships (1:N, N:N, nested resources)
3. Clarify consumers: public API? internal? mobile? third-party?

### Step 2 — Choose the Style

| Style | Best for | Avoid when |
|-------|----------|------------|
| REST | CRUD-heavy, resource-oriented | Complex queries needing joins |
| GraphQL | Frontend-driven, nested data | Simple CRUD, server-to-server |
| RPC/gRPC | Internal microservices, streaming | Public-facing browser clients |

### Step 3 — Endpoint Design (REST)

Follow these conventions:
- **Nouns for resources:** `/users`, `/orders` — never `/getUsers`
- **HTTP verbs for actions:** GET (read), POST (create), PUT/PATCH (update), DELETE
- **Plural collection names:** `/users` not `/user`
- **Nested resources for ownership:** `/users/{id}/orders`
- **Max 2 levels of nesting:** beyond that, promote to top-level with filter params
- **Query params for filtering:** `GET /users?role=admin&active=true`

### Step 4 — Versioning Strategy

| Strategy | Example | Tradeoff |
|----------|---------|----------|
| URL path | `/v1/users` | Simple, visible, hard to sunset |
| Header | `Accept: application/vnd.api.v2+json` | Clean URLs, harder to test |
| Query param | `/users?version=2` | Easy to test, clutters params |

**Default recommendation:** URL path versioning (`/v1/`) for public APIs.

### Step 5 — Error Response Format

Use a consistent error envelope:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Email is required",
    "details": [
      { "field": "email", "issue": "required" }
    ]
  }
}
```

Map to HTTP status codes:
- 400 — validation errors
- 401 — not authenticated
- 403 — not authorized
- 404 — resource not found
- 409 — conflict (duplicate, state mismatch)
- 422 — unprocessable (valid syntax, invalid semantics)
- 429 — rate limited
- 500 — server error (never leak internals)

### Step 6 — Pagination

Choose one pattern:

| Pattern | Example | Best for |
|---------|---------|----------|
| Offset/limit | `?offset=20&limit=10` | Simple, allows jumping to page N |
| Cursor-based | `?cursor=abc123&limit=10` | Large datasets, real-time feeds |
| Keyset | `?after_id=42&limit=10` | Stable ordering, high performance |

Always return pagination metadata:
```json
{ "data": [...], "pagination": { "total": 100, "next_cursor": "abc" } }
```

### Step 7 — Rate Limiting

- Return `429 Too Many Requests` with `Retry-After` header
- Include rate limit headers: `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`
- Design tiers: anonymous < authenticated < premium

### Step 8 — Documentation Checklist

- [ ] Every endpoint has request/response examples
- [ ] Error codes are documented with resolution steps
- [ ] Auth requirements are clear per endpoint
- [ ] Breaking changes are versioned
- [ ] Rate limits are documented

## Output Format

```markdown
## API Design Spec: {service/domain}

### Overview
- Style: REST / GraphQL / RPC
- Consumers: {who uses this API}
- Auth: {auth strategy}
- Versioning: {strategy}

### Endpoints

#### {METHOD} {path}
- Purpose: {what it does}
- Request: {body/params}
- Response: {shape}
- Errors: {error codes}
- Auth: {required/optional/none}

### Design Decisions
| Decision | Choice | Rationale |
|----------|--------|-----------|
| Versioning | {strategy} | {why} |
| Pagination | {pattern} | {why} |
| Error format | {format} | {why} |

### Checklist
- [ ] All endpoints documented with examples
- [ ] Error codes with resolution steps
- [ ] Auth requirements clear per endpoint
- [ ] Rate limits documented
- [ ] Breaking changes versioned
```

## Rules

- Follow REST naming conventions: plural nouns, HTTP verbs for actions
- Never expose internal implementation details in API surface
- Every endpoint must have documented error responses
- Versioning strategy must be decided before first public endpoint
- Pagination is required for any list endpoint returning unbounded results
- Rate limiting headers are required for public APIs
- Use consistent error envelope format across all endpoints
- Max 2 levels of URL nesting — beyond that, promote to top-level with filter params

## Not Responsible For

- Implementing the API (see plan, ultrawork)
- Code review of existing API code (see review)
- Security audit of API auth flows (see security-review)
- Performance testing of endpoints (see perf-audit)
- Database schema design (out of scope)
