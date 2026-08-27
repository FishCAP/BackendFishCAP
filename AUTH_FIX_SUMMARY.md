# Authentication Fix Summary

## Issues Found and Fixed

### 1. **Missing Register Endpoint**
**Problem:** Frontend calls `/auth/register` but the endpoint didn't exist in AuthController
**Fix:** Added `@Post('register')` endpoint in `auth.controller.ts`

### 2. **No JWT Token Generation**
**Problem:** Login didn't generate JWT tokens that the frontend expects
**Fix:** 
- Added `@nestjs/jwt` package to dependencies
- Updated `auth.service.ts` to generate JWT tokens on login and registration
- Configured JwtModule in `app.module.ts`

### 3. **Missing JWT Dependencies**
**Problem:** No JWT packages installed
**Fix:** Added `@nestjs/jwt` and `jsonwebtoken` packages via npm install

### 4. **Database Configuration Issues**
**Problem:** Database module was empty and not properly configured
**Fix:** 
- Updated `database.module.ts` with proper TypeORM configuration
- Enabled `synchronize: true` to auto-create tables from entities
- Added logging for debugging

### 5. **Config Module Not Working**
**Problem:** Config module was not properly configured
**Fix:** Updated `config.module.ts` to properly import and configure NestConfigModule

### 6. **Response Format Mismatch**
**Problem:** Backend responses didn't match frontend expectations
**Fix:** Updated controllers to return `{success: true, data: {...}}` format

### 7. **Missing /users/me Endpoint**
**Problem:** Frontend calls `/users/me` to fetch user profile after login
**Fix:** Added `@Get('me')` endpoint in `users.controller.ts`

## Files Modified

1. **package.json** - Added @nestjs/jwt dependency
2. **.env** - Added JWT_SECRET and JWT_EXPIRES_IN configuration
3. **src/modules/auth/auth.service.ts** - Added JWT token generation
4. **src/modules/auth/auth.controller.ts** - Added register endpoint and proper response format
5. **src/modules/users/users.controller.ts** - Added /users/me endpoint
6. **src/config/config.module.ts** - Fixed configuration module
7. **src/database/database.module.ts** - Added proper database configuration
8. **src/app.module.ts** - Added JwtModule and DatabaseModule imports

## How to Test

1. **Install dependencies:**
   ```bash
   cd Backend-FishCap-project/fishcap-backend
   npm install
   ```

2. **Start PostgreSQL database** (if not already running)

3. **Start the backend server:**
   ```bash
   npm run start:dev
   ```

4. **Test Registration:**
   - Use the Flutter app to register a new user
   - Check that the user is created in the database
   - Verify that a JWT token is returned

5. **Test Login:**
   - Login with the registered user credentials
   - Verify that login succeeds
   - Verify that a JWT token is returned and stored

## Database Schema

The application uses PostgreSQL with the following tables:
- users
- ponds
- devices
- feed_schedules
- feeding_logs
- sensor_data
- notifications

Tables will be auto-created on first run due to `synchronize: true`.

## Security Notes

- Passwords are hashed using SHA256 before storage
- JWT tokens expire after 24 hours (configurable in .env)
- Change the JWT_SECRET in production environment

## Demo User

A demo user is seeded in the database:
- Email: demo@fishcap.local
- Password: demo

---

# Pond Create/Update 401 Fix (Round 2)

## Symptoms

`POST /api/ponds` from the Flutter app returned:

```json
{"statusCode": 401, "message": "Unauthorized", "error": "UnauthorizedException", "path": "/api/ponds"}
```

Ponds could not be created or updated even when already logged in.

## Root Causes Found and Fixed

### 1. JWT_SECRET Mismatch Between Environments (primary 401 cause)
**Problem:** `docker-compose.yml` did not pass `JWT_SECRET` into the API container,
and the Docker runtime image does not contain `.env`. The container therefore
fell back to a *different* default secret (`super_secret_fallback_key_for_development`)
than the one used for local dev signing (`your-secret-key-change-this-in-production`
from `.env`). Tokens minted with one key failed verification in the other
environment — permanent 401 for every saved session.

**Fix:**
- `docker-compose.yml` now injects `JWT_SECRET` (and `JWT_EXPIRES_IN`) into the
  backend container.
- The fallback constants in `auth.module.ts` (signing) and `jwt.strategy.ts`
  (verification) are identical, so they can never diverge again.

### 2. Frontend Had No Stale-Token Recovery
**Problem:** `ApiService._authHeaders()` silently omitted the Authorization header
when `token == null`, requests showed the raw "Unauthorized" error, and dead
tokens were never cleared — so the app kept looping on 401.
Additionally there was a cold-start race: screens could fire requests before the
async `loadToken()` finished.

**Fix (`lib/services/api_service.dart`, `lib/main.dart`):**
- New `_sendAuthenticated()` wrapper around **every** guarded endpoint (ponds
  CRUD, profile, sensors, feed-schedules): on a 401 it reloads the persisted
  token once and retries; if the retry still 401s it clears the dead token so
  the app lands back on login cleanly.
- `main()` is now async: it loads the token and probes `/users/me` *before*
  `runApp`, choosing `/schedule` only when a valid session exists (no more race).
- 401 responses are humanized to "Your session has expired. Please sign in again."
- Legacy create/update retry payloads no longer send non-whitelisted keys
  (`pondName`/`fishType`/`fishCount`), which caused guaranteed 400s under
  `forbidNonWhitelisted`.

### 3. App's Real Payload Was Rejected With 400 After Auth Was Fixed
**Problem:** The Create/Edit Pond screen sends `feedingSchedules:
[{time, amount}]`, which was not whitelisted in `CreatePondDto` /
`UpdatePondDto`, so the global ValidationPipe rejected it. Also, PATCHing with
optional fields as `undefined` wiped existing columns (`location`, `species`,
`hardwareId`) to NULL via `Object.assign`.

**Fix:**
- Both DTOs whitelist `feedingSchedules` (nested validation, max 20 entries).
- `PondsService.normalizePondPayload()` derives `feedingTimes` + total `amount`
  from the schedule array, drops keys whose value is `undefined` (partial updates
  can no longer null-out columns), and never persists the raw schedules array.

## Files Modified (Round 2)

1. **Backend**
   - `src/modules/auth/jwt.strategy.ts` – aligned fallback secret
   - `src/modules/auth/auth.module.ts` – aligned fallback secret
   - `docker-compose.yml` – inject JWT_SECRET/JWT_EXPIRES_IN into the container
   - `src/modules/ponds/dto/create-pond.dto.ts` + `update-pond.dto.ts` – whitelist `feedingSchedules`
   - `src/modules/ponds/ponds.service.ts` – payload normalization / undefined filtering
2. **Frontend**
   - `lib/services/api_service.dart` – `_sendAuthenticated` wrapper + retry/clear logic on all guarded endpoints; fixed legacy retry payloads; better error messages
   - `lib/main.dart` – async bootstrap, valid-session route selection

## How to Verify (Round 2)

```bash
cd Backend-FishCap-project/fishcap-backend
docker compose up -d --build backend          # rebuild with new code + JWT env
TOKEN=$(curl -s -X POST http://localhost:3001/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"demo@fishcap.local","password":"demo"}' | python3 -c "import sys,json;print(json.load(sys.stdin)['data']['token'])")
curl -s http://localhost:3001/api/users/me -H "Authorization: Bearer $TOKEN"    # probe works
curl -s -X POST http://localhost:3001/api/ponds -H "Authorization: Bearer $TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{"name":"Test","feedingSchedules":[{"time":"08:00","amount":1.5}]}'
```

**Important:** after deploying these changes, do one fresh login in the app
(full restart). Tokens issued before the secret alignment are invalid by design;
the app now detects this, clears them automatically, and returns to login.
- Password: demo