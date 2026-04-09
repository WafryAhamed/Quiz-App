# Quiz Learning Platform (Flutter + Spring Boot + FastAPI + MongoDB)

Production-style multi-service architecture for AI-powered quiz generation from PDFs.

## Architecture

- `mobile-app/` → Flutter mobile app
- `backend-java/` → Spring Boot REST + JWT + WebSocket + MongoDB
- `ai-service/` → FastAPI AI service (PDF extraction + quiz generation)

Flow:

`Flutter → Spring Boot → FastAPI → MongoDB`

## Quick Start

### 1) Start MongoDB

Ensure MongoDB is running locally at:

- `mongodb://localhost:27017/quiz_learning_db`

### 2) Start AI service

From `ai-service/`:

- Install deps: `python -m pip install -r requirements.txt`
- Run: `python -m uvicorn app.main:app --host 127.0.0.1 --port 8000`

### 3) Start Java backend

From `backend-java/`:

- Run tests: `mvn test`
- Start app: `mvn spring-boot:run`

### 4) Start Flutter app

From `mobile-app/`:

- Install deps: `flutter pub get`
- Analyze: `flutter analyze`
- Run: `flutter run`

## Environment Variables

### `backend-java/.env`

- `MONGODB_URI`
- `JWT_SECRET`
- `JWT_EXPIRATION_MS`
- `AI_SERVICE_URL`
- `UPLOAD_DIR`

### `ai-service/.env`

- `OPENAI_API_KEY` (optional; fallback generation works without it)
- `OPENAI_MODEL`
- `MAX_QUIZ_QUESTIONS`

### `mobile-app/.env`

- `API_BASE_URL`
- `WS_BASE_URL`

## Core Backend APIs

### Auth
- `POST /auth/register`
- `POST /auth/login`

### PDF
- `POST /pdf/upload`

### Quiz
- `GET /quiz/{pdfId}`
- `POST /quiz/submit`

### Live Quiz
- `POST /live/create`
- `POST /live/join`
- `POST /live/start/{code}`
- `POST /live/next/{code}/{index}`
- `POST /live/answer`

### WebSocket Topics
- `/topic/live/{code}/question`
- `/topic/live/{code}/participants`
- `/topic/live/{code}/leaderboard`

## Verified in this session

- Backend compiles and tests pass (`mvn test`)
- AI service imports, starts, and `/health` + `/generate-quiz` work
- Mobile app dependencies resolve and `flutter analyze` passes cleanly
- End-to-end API flow tested:
  - register users
  - login
  - upload PDF
  - generate quiz via AI
  - submit quiz
  - create/join/start live session
  - submit live answer
