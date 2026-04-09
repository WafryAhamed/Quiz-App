package lk.edu.quizapp.dto.live;

import jakarta.validation.constraints.NotBlank;

public record LiveJoinRequest(
        @NotBlank(message = "code is required")
        String code,

        @NotBlank(message = "userId is required")
        String userId,

        @NotBlank(message = "name is required")
        String name
) {
}
