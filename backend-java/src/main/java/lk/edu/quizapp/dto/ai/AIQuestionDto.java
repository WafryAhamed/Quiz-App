package lk.edu.quizapp.dto.ai;

import java.util.List;

public record AIQuestionDto(
        String question,
        List<String> options,
        String correctAnswer,
        String difficulty
) {
}
