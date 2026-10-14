# Flashcards

Simple flashcard study app: question on the front, answer on the back.

## Stack

| Layer | Tech |
|-------|------|
| Mobile app | **Flutter** (Web, iOS, Android) |
| API | Spring Boot 4.1 / Java 25 |
| DB | PostgreSQL (prod) / H2 (dev) |
| Migrations | Flyway |

## Accounts and data ownership

Users sign up with a **username** and **password** (BCrypt-hashed on the server). The API returns a **JWT**; the Flutter app stores it in `shared_preferences` (`flashcards_token`, `flashcards_user`) and sends `Authorization: Bearer <token>` on card and folder requests.

Each install still has a stable **device id** (`flashcards_device_id`) used only on `POST /api/auth/register` and `POST /api/auth/login`. On first sign-up or log-in from that device, any legacy rows tied to that device id (anonymous `user_id IS NULL`) are **claimed** into the account. After that, library data is owned by `user_id` and syncs on any device after login.

Usernames are stored lowercase, unique case-insensitively (3–32 characters, letters, numbers, underscore).

### Folders

Folders are **user-created** with any name (up to 120 characters, trimmed, unique per account case-insensitively). Cards can live in a folder or in **Unfiled** (`folderId` null). **Deleting a folder** removes the folder only; its cards are moved to Unfiled.

Study mode can run for one folder or the unfiled list. **Shuffle** order is optional, stored locally per device, with reshuffle and restore-to-sorted-order in the study UI.

## Quick start (local)

### 1. Database (optional — prod-like)

```bash
docker compose up -d db
docker compose --profile full up --build api
```

### 2. API (in-memory H2)

```bash
cd backend
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev
```

API: http://localhost:8080  
Health: http://localhost:8080/actuator/health (does not query the DB in `prod`)

### 3. Flutter app

```bash
cd mobile
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080
```

## Deploy (Erlend setup)

### Neon Postgres (free)

1. Create a project and database (e.g. `flashcards`).
2. Copy the **JDBC** connection string and append `?sslmode=require` if needed.
3. Note username and password.

### Render (free Docker web service)

1. Connect this GitHub repo to Render (or use **Blueprint** with `render.yaml`).
2. Create the `flashcards-api` web service from `render.yaml` (Docker, health check `/actuator/health`).
3. Set environment variables (never commit these):

   | Variable | Value |
   |----------|--------|
   | `DATABASE_URL` | Neon JDBC URL |
   | `DATABASE_USER` | Neon user |
   | `DATABASE_PASSWORD` | Neon password |
   | `CORS_ORIGINS` | Optional extra origins (comma-separated) |
   | `JWT_SECRET` | **Required in production** (`prod` profile fails to start without it). HMAC secret for signing JWTs (at least 32 random bytes; never commit). The `dev` profile alone supplies a throwaway default when unset. |
   | `JWT_EXPIRATION_MS` | Optional. Token lifetime in ms (default `604800000` = 7 days). |

4. Deploy from `main`; note the public API URL (e.g. `https://flashcards-api-ugap.onrender.com`).

Prod uses Hikari `minimum-idle: 0` and a 60s idle timeout for Neon suspend; DB health check is disabled so Render health checks do not wake the database.

### Firebase Hosting (Flutter web)

1. Create a Firebase project and enable **Hosting**.
2. Update `mobile/.firebaserc` `default` project id to your Firebase project.
3. Create a service account with Firebase Hosting Admin and download JSON.

### GitHub Actions secrets

Add these in the repo **Settings → Secrets and variables → Actions**:

| Secret | Purpose |
|--------|---------|
| `FIREBASE_SERVICE_ACCOUNT` | JSON key for Firebase deploy action |
| `FIREBASE_PROJECT_ID` | Firebase project id (e.g. `my-flashcards`) |
| `FLASHCARDS_API_BASE_URL` | Public Render API URL passed as `--dart-define=API_BASE_URL` at web build time |

`GITHUB_TOKEN` is provided automatically for the hosting deploy action.

After deploy, set `AppConfig.productionApiBaseUrl` in `mobile/lib/core/config.dart` to match your Render URL (or rely on `FLASHCARDS_API_BASE_URL` in CI only).

Workflows:

- `.github/workflows/ci.yml` — Maven tests + `flutter analyze` / `flutter test`
- `.github/workflows/firebase-hosting.yml` — build web and deploy `mobile/` on pushes to `main`

## Project layout

```text
backend/   Spring Boot REST API
mobile/    Flutter app
render.yaml
docker-compose.yml
```

## API

Card and folder routes require `Authorization: Bearer <jwt>` from `/api/auth/register` or `/api/auth/login`. Register and login accept optional `X-Device-Id` to claim anonymous device data.

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/auth/register` | `{ "username", "password" }` → `{ "token", "user" }` |
| POST | `/api/auth/login` | `{ "username", "password" }` → `{ "token", "user" }` |
| GET | `/api/auth/me` | Current user (Bearer token) |
| GET | `/api/folders` | Library summary: folders + card counts + `unfiledCount` |
| POST | `/api/folders` | Create `{ "name" }` |
| PUT | `/api/folders/{id}` | Rename |
| DELETE | `/api/folders/{id}` | Delete folder (cards → Unfiled) |
| GET | `/api/cards` | List cards (`?folderId=`, `?unfiled=true`, or all) |
| POST | `/api/cards` | Create `{ "question", "answer", "folderId"? }` |
| GET | `/api/cards/{id}` | Get one card |
| PUT | `/api/cards/{id}` | Update |
| DELETE | `/api/cards/{id}` | Delete |
| POST | `/api/cards/bulk-delete` | `{ "ids": [uuid, ...] }` |
| POST | `/api/cards/bulk-move` | `{ "ids": [...], "folderId": uuid \| null }` |
