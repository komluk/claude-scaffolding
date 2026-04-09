# Authentication and Authorization Review Checklist

Use when reviewing auth-related code changes.

## Authentication Flow
- [ ] Login endpoint rate-limited (max 5 attempts/minute)
- [ ] Password hashing uses bcrypt or argon2 with appropriate cost factor
- [ ] Failed login returns generic error (no user enumeration)
- [ ] Account lockout after 10 consecutive failures
- [ ] Password reset tokens are single-use and expire in 1 hour

## Token Management (JWT)
- [ ] Access token expiry: 15 minutes max
- [ ] Refresh token expiry: 7 days max
- [ ] Tokens stored in HttpOnly, Secure, SameSite=Strict cookies
- [ ] Never stored in localStorage or sessionStorage
- [ ] Tokens include `iat`, `exp`, `sub` claims
- [ ] Signing algorithm is RS256 or HS256 (not `none`)
- [ ] Token revocation supported (blacklist or short expiry)

## Session Security
- [ ] Session ID regenerated after login
- [ ] Sessions invalidated on logout (server-side)
- [ ] Idle timeout configured (30 minutes recommended)
- [ ] Absolute timeout configured (8 hours recommended)
- [ ] Concurrent session limit enforced if required

## Authorization (RBAC)
- [ ] Every API endpoint has explicit permission check
- [ ] Default deny: no access unless explicitly granted
- [ ] Role hierarchy properly enforced (admin > editor > viewer)
- [ ] Resource-level authorization (users can only access own resources)
- [ ] Admin endpoints protected by separate middleware
- [ ] No authorization logic in frontend only

## Password Policy
- [ ] Minimum 8 characters
- [ ] Maximum 128 characters (prevent DoS via bcrypt)
- [ ] Check against common password list (top 10k)
- [ ] No composition rules forced (NIST 800-63B)
- [ ] Password change requires current password

## API Security
- [ ] All endpoints require authentication (except public ones)
- [ ] API keys rotatable and revocable
- [ ] CORS allows only specific origins
- [ ] Request size limits configured
- [ ] Content-Type validation on all inputs

## Logging and Monitoring
- [ ] All auth events logged with timestamp and IP
- [ ] Failed attempts trigger alerts after threshold
- [ ] Successful privilege escalation logged
- [ ] Token refresh events logged
- [ ] No passwords or tokens in log output
