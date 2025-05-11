# Authentication Flow in Applicare

This document explains the JWT-based authentication flow implemented in Applicare.

## Overview

Applicare uses a secure two-token authentication system:

1. **Access Token**: A short-lived JWT token (1 hour) used for API authorization
2. **Refresh Token**: A long-lived token (30 days) stored in the database and used to obtain new access tokens

This approach provides both security and convenience - short-lived access tokens minimize risk while refresh tokens prevent users from having to log in frequently.

## Authentication Flow

### 1. Initial Login

#### For Users:

```http
POST /api/v1/sessions
Content-Type: application/json

{
  "email_address": "user@example.com",
  "password": "password123"
}
```

#### For Repairers:

```http
POST /api/v1/repairer_sessions
Content-Type: application/json

{
  "email_address": "repairer@example.com",
  "password": "password123"
}
```

#### Successful Response:

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiJ9...",
  "refresh_token": "a8b7c6d5e4f3...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "user_id": 123 // (or repairer object for repairer login)
}
```

The server:

1. Validates credentials
2. Generates a JWT access token containing user/repairer ID and expiration time (1 hour)
3. Creates a refresh token in the database with 30-day expiration
4. Returns both tokens to the client

### 2. Accessing Protected Resources

All authenticated API requests include the access token in the header:

```http
GET /api/v1/protected-endpoint
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

The server:

1. Extracts the token from the Authorization header
2. Verifies the JWT signature, expiration, and claims
3. Identifies the user/repairer from the token payload
4. Grants access if the token is valid

### 3. Token Refresh

When the access token expires (after 1 hour), the client uses the refresh token to get a new pair of tokens:

```http
POST /api/v1/token/refresh
Content-Type: application/json

{
  "refresh_token": "a8b7c6d5e4f3..."
}
```

#### Successful Response:

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiJ9...(new)",
  "refresh_token": "g9h8i7j6k5l4...(new)",
  "token_type": "Bearer",
  "expires_in": 3600
}
```

The server:

1. Verifies the refresh token exists in the database
2. Checks that it's not expired or already used
3. Identifies the associated user/repairer
4. Marks the current refresh token as used (preventing replay attacks)
5. Issues a new access token and refresh token pair
6. Returns both new tokens to the client

### 4. Logout

```http
DELETE /api/v1/sessions/current
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

or for repairers:

```http
DELETE /api/v1/repairer_sessions/current
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

The server:

1. Authenticates the request using the access token
2. Finds all active refresh tokens for the user/repairer
3. Marks all refresh tokens as used, invalidating them
4. Returns success message

## Security Features

The authentication system includes several security features:

1. **Short-lived access tokens**: Access tokens expire after 1 hour, limiting the window of opportunity if a token is compromised
2. **Single-use refresh tokens**: Each refresh token can only be used once, preventing replay attacks
3. **Database-backed refresh tokens**: Refresh tokens can be invalidated server-side if needed
4. **Complete revocation on logout**: All refresh tokens are invalidated when a user logs out
5. **Separate token types**: Separation of access and refresh token concerns
6. **JWT signature verification**: All access tokens are cryptographically signed and verified
7. **HTTPS-only**: All authentication communication should occur over HTTPS

## Implementation Details

### JWT Payload Structure

Access tokens contain:

- `user_id` or `repairer_id`: Identifies the authenticated entity
- `exp`: Expiration timestamp (1 hour from issuance)
- `iat`: Issued at timestamp

### RefreshToken Model

The database stores refresh tokens with:

- `token`: The actual token string
- `user_id`/`repairer_id`: Associated account (polymorphic)
- `expires_at`: Expiration date (30 days from issuance)
- `used`: Boolean flag to track if the token has been used
- `created_at`/`updated_at`: Timestamps

## Best Practices for Clients

Clients should:

1. Store the refresh token securely (e.g., in secure HTTP-only cookies)
2. Include the access token in all API requests
3. Handle 401 Unauthorized responses by attempting a token refresh
4. If refresh fails, redirect to login

## Debugging Authentication Issues

Common authentication errors:

- `401 Unauthorized` with "Token expired": Access token has expired
- `401 Unauthorized` with "Invalid token": Token signature validation failed
- `401 Unauthorized` with "Invalid or expired refresh token": Refresh token is invalid, used, or expired
- `400 Bad Request` with "Refresh token is required": Missing refresh token in request
