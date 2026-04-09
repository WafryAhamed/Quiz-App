package lk.edu.quizapp.dto.live;

import jakarta.validation.constraints.NotBlank;

public record LiveCreateRequest(
        @NotBlank(message = "lecturerId is required")
        String lecturerId,

        @NotBlank(message = "pdfId is required")
        String pdfId
) {
}
