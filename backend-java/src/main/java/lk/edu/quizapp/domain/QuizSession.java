package lk.edu.quizapp.domain;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "quizSessions")
public class QuizSession {

    @Id
    private String id;

    private String code;
    private String lecturerId;

    @Builder.Default
    private List<String> questionIds = new ArrayList<>();

    @Builder.Default
    private List<Participant> participants = new ArrayList<>();

    @Builder.Default
    private List<LeaderboardEntry> leaderboard = new ArrayList<>();

    private boolean active;
    private Instant createdAt;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Participant {
        private String userId;
        private String name;
        private int score;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class LeaderboardEntry {
        private String userId;
        private String name;
        private int score;
    }
}
