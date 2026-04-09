package lk.edu.quizapp.dto.live;

import lk.edu.quizapp.domain.QuizSession;

import java.util.List;

public record LiveSessionResponse(
        String sessionId,
        String code,
        int participantCount,
        List<QuizSession.LeaderboardEntry> leaderboard
) {
}
