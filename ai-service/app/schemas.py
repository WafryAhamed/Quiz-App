from pydantic import BaseModel, Field
from typing import List


class QuizQuestion(BaseModel):
    question: str = Field(..., min_length=5)
    options: List[str] = Field(..., min_length=2, max_length=6)
    correctAnswer: str = Field(..., min_length=1)
    difficulty: str = Field(default="medium")


class QuizResponse(BaseModel):
    questions: List[QuizQuestion]
