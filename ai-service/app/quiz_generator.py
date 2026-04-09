import json
import logging
import os
import random
import re
from collections import Counter
from typing import Any, List, Optional

import fitz
from dotenv import load_dotenv
from openai import OpenAI

from .schemas import QuizQuestion

load_dotenv()
logger = logging.getLogger(__name__)


def extract_text_from_pdf(pdf_bytes: bytes) -> str:
    """Extract text from PDF bytes using PyMuPDF."""
    try:
        with fitz.open(stream=pdf_bytes, filetype="pdf") as document:
            pages = [str(page.get_text("text")) for page in document]
        return "\n".join(pages).strip()
    except Exception as exc:
        raise ValueError(f"Unable to read PDF file: {exc}") from exc


class QuizGenerator:
    def __init__(self) -> None:
        raw_key = os.getenv("OPENAI_API_KEY", "").strip()
        placeholder_prefixes = (
            "replace_",
            "your_",
            "sk-your-",
            "<",
        )

        if not raw_key or raw_key.lower().startswith(placeholder_prefixes):
            self.api_key = ""
        else:
            self.api_key = raw_key

        self.model = os.getenv("OPENAI_MODEL", "gpt-4o-mini")
        self.client: Optional[OpenAI] = None

        if self.api_key:
            try:
                self.client = OpenAI(api_key=self.api_key)
            except Exception as exc:
                logger.warning("OpenAI client initialization failed. Falling back to local quiz generation: %s", exc)
                self.client = None

    def generate_quiz(self, text: str, question_count: int = 10) -> List[QuizQuestion]:
        clean_text = self._clean_text(text)
        if len(clean_text) < 100:
            raise ValueError("Not enough text content to generate a meaningful quiz")

        if self.client:
            try:
                return self._generate_with_openai(clean_text, question_count)
            except Exception:
                # If AI provider fails, fall back to deterministic local generation.
                pass

        return self._generate_fallback(clean_text, question_count)

    def _generate_with_openai(self, text: str, question_count: int) -> List[QuizQuestion]:
        if self.client is None:
            raise ValueError("OpenAI client is not configured")

        prompt = f"""
You are an expert university lecturer from Sri Lanka creating quiz questions.
Use the given study material and create exactly {question_count} MCQs.
Return ONLY valid JSON in this exact shape:
{{
  "questions": [
    {{
      "question": "...",
      "options": ["...", "...", "...", "..."],
      "correctAnswer": "...",
      "difficulty": "easy|medium|hard"
    }}
  ]
}}

Rules:
- Questions must be clear for undergraduates from universities like University of Moratuwa, University of Colombo, and University of Peradeniya.
- correctAnswer must be one of the options.
- No markdown fences.
- No explanation text.

Study material:
{text[:12000]}
"""

        response = self.client.responses.create(
            model=self.model,
            input=prompt,
            temperature=0.4,
        )

        output_text = getattr(response, "output_text", "") or ""
        payload = self._parse_json(output_text)
        questions_data = payload.get("questions", [])

        if not questions_data:
            raise ValueError("AI model returned empty questions")

        questions = [QuizQuestion(**question) for question in questions_data]
        return [self._normalize_question(question) for question in questions][:question_count]

    def _generate_fallback(self, text: str, question_count: int) -> List[QuizQuestion]:
        words = re.findall(r"[A-Za-z][A-Za-z-]{3,}", text)
        keywords = [word.lower() for word in words if word.lower() not in {"with", "from", "that", "this", "have", "will"}]
        common = [word for word, _ in Counter(keywords).most_common(20)]

        if len(common) < 4:
            common = ["learning", "analysis", "system", "model", "data", "algorithm"]

        questions: List[QuizQuestion] = []
        difficulties = ["easy", "medium", "hard"]

        for i in range(question_count):
            anchor = common[i % len(common)]
            distractors = random.sample(common, k=min(3, len(common)))
            correct_option = f"It explains the concept of {anchor}."
            options = [
                correct_option,
                f"It rejects the relevance of {distractors[0]}.",
                f"It only focuses on the history of {distractors[1] if len(distractors) > 1 else anchor}.",
                f"It avoids practical use of {distractors[2] if len(distractors) > 2 else anchor}.",
            ]
            random.shuffle(options)

            question = QuizQuestion(
                question=f"Based on the document, what is most accurate about '{anchor}'?",
                options=options,
                correctAnswer=correct_option,
                difficulty=difficulties[i % len(difficulties)],
            )
            questions.append(self._normalize_question(question))

        return questions

    def _clean_text(self, text: str) -> str:
        return re.sub(r"\s+", " ", text).strip()

    def _parse_json(self, text: str) -> dict[str, Any]:
        raw = text.strip()
        if raw.startswith("```"):
            raw = raw.strip("`")
            if raw.startswith("json"):
                raw = raw[4:].strip()

        if not raw.startswith("{"):
            match = re.search(r"\{.*\}", raw, re.DOTALL)
            if match:
                raw = match.group(0)

        return json.loads(raw)

    def _normalize_question(self, question: QuizQuestion) -> QuizQuestion:
        unique_options: List[str] = []
        for option in question.options:
            if option not in unique_options:
                unique_options.append(option)

        if question.correctAnswer not in unique_options:
            unique_options.insert(0, question.correctAnswer)

        while len(unique_options) < 4:
            unique_options.append(f"Additional option {len(unique_options) + 1}")

        return QuizQuestion(
            question=question.question,
            options=unique_options[:4],
            correctAnswer=question.correctAnswer,
            difficulty=(question.difficulty or "medium").lower(),
        )
