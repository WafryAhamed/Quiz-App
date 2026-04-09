package lk.edu.quizapp.dto.live;

import jakarta.validation.constraints.NotBlank;

public record LiveAnswerRequest(
        @NotBlank(message = "code is required")
        String code,

        @NotBlank(message = "userId is required")
        String userId,

        @NotBlank(message = "questionId is required")
        String questionId,

        @NotBlank(message = "answer is required")
        String answer
) {
}
