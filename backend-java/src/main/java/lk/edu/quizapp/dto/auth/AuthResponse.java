package lk.edu.quizapp.dto.auth;

public record AuthResponse(
        String token,
        String userId,
        String name,
        String email,
        String role
) {
}
