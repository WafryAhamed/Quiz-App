package lk.edu.quizapp.dto.ai;

import java.util.List;

public record AIQuizResponse(
        List<AIQuestionDto> questions
) {
}
