# OWASP Top 10 Quick Review Checklist

Use during code review. Check each item, mark N/A if not applicable.

## A01: Broken Access Control
- [ ] Authorization checked on every endpoint (not just frontend)
- [ ] CORS configured with explicit allowed origins (no wildcards)
- [ ] Directory listing disabled
- [ ] JWT tokens validated server-side on each request
- [ ] Resource IDs cannot be tampered to access other users' data

## A02: Cryptographic Failures
- [ ] Sensitive data encrypted at rest (AES-256)
- [ ] TLS 1.2+ enforced for all connections
- [ ] No secrets in source code, logs, or error messages
- [ ] Passwords hashed with bcrypt/argon2 (not MD5/SHA1)

## A03: Injection
- [ ] All SQL uses parameterized queries (SQLAlchemy ORM or `text()` with params)
- [ ] User input validated with Pydantic schemas
- [ ] No string concatenation in queries or shell commands
- [ ] HTML output properly escaped (React does this by default)

## A04: Insecure Design
- [ ] Rate limiting on authentication endpoints
- [ ] Business logic validates server-side (not just client)
- [ ] Fail-secure defaults (deny by default)

## A05: Security Misconfiguration
- [ ] DEBUG=False in production
- [ ] Stack traces not exposed to users
- [ ] Default credentials changed
- [ ] Security headers set (HSTS, X-Content-Type-Options, CSP)
- [ ] Unnecessary features/endpoints disabled

## A06: Vulnerable Components
- [ ] Dependencies pinned to specific versions
- [ ] No known CVEs in dependencies (check `pip audit` / `npm audit`)
- [ ] Base Docker images use `-alpine` or `-slim` variants

## A07: Auth Failures
- [ ] Passwords enforce minimum complexity (8+ chars)
- [ ] Account lockout after failed attempts
- [ ] Session tokens invalidated on logout
- [ ] Tokens have reasonable expiry (access: 15min, refresh: 7d)

## A08: Data Integrity Failures
- [ ] CI/CD pipeline uses pinned action versions
- [ ] Package integrity verified (lock files committed)
- [ ] No unsigned or unverified deserialization

## A09: Logging Failures
- [ ] Authentication events logged (login, logout, failed attempts)
- [ ] Authorization failures logged
- [ ] No PII or secrets in log output
- [ ] Logs include correlation IDs for request tracing

## A10: SSRF
- [ ] User-supplied URLs validated against allowlist
- [ ] Internal network addresses blocked in outbound requests
- [ ] URL redirects validated against known destinations
