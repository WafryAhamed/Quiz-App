package lk.edu.quizapp.dto.quiz;

import java.util.List;

public record QuizQuestionResponse(
        String id,
        String question,
        List<String> options,
        String difficulty
) {
}
