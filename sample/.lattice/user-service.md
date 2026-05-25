# User Service -- Requirements

## Overview

A .NET 8 Web API service that manages user registration, authentication, and profile management. This is a bounded context for user identity within a larger system.

## Tech Stack

- .NET 8 / C# 12
- ASP.NET Core Web API (minimal APIs or controllers -- to be decided during design)
- Entity Framework Core 8 (PostgreSQL)
- FluentValidation for input validation
- xUnit + NSubstitute for testing

## Capabilities

### 1. User Registration

A new user registers with email and password. The system must:

- Validate email format and uniqueness (no duplicate emails)
- Enforce password policy: minimum 8 characters, at least one uppercase, one lowercase, one digit
- Hash passwords before storage (never store plaintext)
- Assign a unique UserId (GUID) at creation time
- Record the registration timestamp
- Return the created user profile (without password)

### 2. User Authentication

A registered user authenticates with email and password. The system must:

- Look up user by email
- Verify the provided password against the stored hash
- Return a success/failure result (no token generation -- that is a separate service's concern)
- Track the last login timestamp on successful authentication
- Enforce account lockout after 5 consecutive failed attempts (unlock after 30 minutes)

### 3. User Profile Management

An authenticated user can view and update their profile. The system must:

- Retrieve a user profile by UserId
- Allow updating: display name, phone number
- NOT allow updating: email, password (those are separate flows, out of scope)
- Validate phone number format when provided (E.164 format)
- Track the last modified timestamp

## Domain Concepts

- **User**: The core entity with identity, registration state, and profile data
- **Email**: Must be valid format, unique across users -- a good candidate for a value object
- **Password**: Has policy rules, must be hashed -- the raw password should never exist as a stored field
- **Phone Number**: E.164 format validation -- another value object candidate
- **Account Lockout**: Tracks failed attempts and lockout expiry -- an invariant the User aggregate should enforce

## Constraints

- No external API calls -- this is a standalone service
- No event publishing (keep it simple for now)
- No caching layer
- Database is the sole persistence mechanism
- All endpoints should return appropriate HTTP status codes (201 for creation, 400 for validation errors, 401 for auth failures, 404 for not found, 429 for locked accounts)

## Non-Functional

- All user input must be validated at the API boundary
- Passwords must never appear in logs or error messages
- Failed authentication should not reveal whether the email exists (prevent user enumeration)
