package lk.edu.quizapp.dto.quiz;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;

import java.util.List;

public record QuizSubmitRequest(
        @NotBlank(message = "pdfId is required")
        String pdfId,

        @NotEmpty(message = "answers are required")
        List<AnswerItem> answers
) {
    public record AnswerItem(
            @NotBlank(message = "questionId is required")
            String questionId,

            @NotBlank(message = "answer is required")
            String answer
    ) {
    }
}
