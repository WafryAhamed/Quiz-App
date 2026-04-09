# ai-service

FastAPI-based AI service for generating MCQ quizzes from PDF files.

## Run

1. Update `.env` (OpenAI key optional)
2. Install deps: `python -m pip install -r requirements.txt`
3. Start: `python -m uvicorn app.main:app --host 127.0.0.1 --port 8000`

## Endpoint

- `POST /generate-quiz`
  - accepts `file` (PDF) or `extracted_text`
  - returns `{ "questions": [...] }`

- `GET /health`
