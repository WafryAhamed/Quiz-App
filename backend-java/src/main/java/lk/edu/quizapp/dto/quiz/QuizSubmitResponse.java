package lk.edu.quizapp.dto.quiz;

import java.util.Map;

public record QuizSubmitResponse(
        int totalQuestions,
        int correctAnswers,
        double scorePercentage,
        Map<String, Boolean> perQuestionResult
) {
}
