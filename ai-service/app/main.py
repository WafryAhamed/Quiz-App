import os
from typing import Optional

from dotenv import load_dotenv
from fastapi import FastAPI, File, Form, HTTPException, UploadFile

from .quiz_generator import QuizGenerator, extract_text_from_pdf
from .schemas import QuizResponse

load_dotenv()

app = FastAPI(title="Quiz AI Service", version="1.0.0")
quiz_generator = QuizGenerator()
MAX_QUIZ_QUESTIONS = int(os.getenv("MAX_QUIZ_QUESTIONS", "10"))


@app.get("/health")
def health_check() -> dict[str, str]:
    return {"status": "ok", "service": "ai-service"}


@app.post("/generate-quiz", response_model=QuizResponse)
async def generate_quiz(
    file: Optional[UploadFile] = File(default=None),
    extracted_text: Optional[str] = Form(default=None),
    question_count: int = Form(default=10),
) -> QuizResponse:
    """
    Accepts either:
    1) A PDF file, or
    2) Extracted plain text.
    Returns a normalized quiz structure expected by the Spring Boot backend.
    """

    if file is None and not extracted_text:
        raise HTTPException(status_code=400, detail="Provide either a PDF file or extracted_text")

    bounded_count = max(1, min(question_count, MAX_QUIZ_QUESTIONS))

    try:
        if file is not None:
            if file.content_type not in {"application/pdf", "application/octet-stream"}:
                raise HTTPException(status_code=400, detail="Only PDF upload is supported")

            pdf_bytes = await file.read()
            if not pdf_bytes:
                raise HTTPException(status_code=400, detail="Uploaded PDF is empty")

            source_text = extract_text_from_pdf(pdf_bytes)
        else:
            source_text = extracted_text or ""

        questions = quiz_generator.generate_quiz(source_text, bounded_count)
        return QuizResponse(questions=questions)
    except HTTPException:
        raise
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"Failed to generate quiz: {exc}") from exc
