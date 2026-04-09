package lk.edu.quizapp.service;

import lk.edu.quizapp.domain.Question;
import lk.edu.quizapp.domain.QuizSession;
import lk.edu.quizapp.domain.User;
import lk.edu.quizapp.domain.UserRole;
import lk.edu.quizapp.dto.live.LiveAnswerRequest;
import lk.edu.quizapp.dto.live.LiveCreateRequest;
import lk.edu.quizapp.dto.live.LiveJoinRequest;
import lk.edu.quizapp.dto.live.LiveSessionResponse;
import lk.edu.quizapp.dto.quiz.QuizQuestionResponse;
import lk.edu.quizapp.exception.BadRequestException;
import lk.edu.quizapp.exception.ResourceNotFoundException;
import lk.edu.quizapp.repository.QuestionRepository;
import lk.edu.quizapp.repository.QuizSessionRepository;
import lk.edu.quizapp.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import java.security.SecureRandom;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;

@Slf4j
@Service
@RequiredArgsConstructor
public class LiveQuizService {

    private static final String CODE_CHARACTERS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";

    private final QuizSessionRepository quizSessionRepository;
    private final QuestionRepository questionRepository;
    private final UserRepository userRepository;
    private final SimpMessagingTemplate messagingTemplate;

    private final SecureRandom secureRandom = new SecureRandom();

    public LiveSessionResponse createSession(LiveCreateRequest request) {
        User lecturer = userRepository.findById(request.lecturerId())
                .orElseThrow(() -> new ResourceNotFoundException("Lecturer not found: " + request.lecturerId()));

        if (lecturer.getRole() != UserRole.LECTURER) {
            throw new BadRequestException("Only lecturers can create live quiz sessions");
        }

        List<Question> questions = questionRepository.findByPdfId(request.pdfId());
        if (questions.isEmpty()) {
            throw new BadRequestException("No generated questions found for PDF: " + request.pdfId());
        }

        QuizSession session = QuizSession.builder()
                .code(generateUniqueCode())
                .lecturerId(lecturer.getId())
                .questionIds(questions.stream().map(Question::getId).toList())
                .participants(new ArrayList<>())
                .leaderboard(new ArrayList<>())
                .active(false)
                .createdAt(Instant.now())
                .build();

        QuizSession savedSession = quizSessionRepository.save(session);
        log.info("Created live quiz session {} by lecturer {}", savedSession.getCode(), lecturer.getEmail());

        return toResponse(savedSession);
    }

    public LiveSessionResponse joinSession(LiveJoinRequest request) {
        QuizSession session = findSessionByCode(request.code());

        boolean alreadyParticipant = session.getParticipants().stream()
                .anyMatch(participant -> participant.getUserId().equals(request.userId()));

        if (!alreadyParticipant) {
            session.getParticipants().add(QuizSession.Participant.builder()
                    .userId(request.userId())
                    .name(request.name())
                    .score(0)
                    .build());

            session.getLeaderboard().add(QuizSession.LeaderboardEntry.builder()
                    .userId(request.userId())
                    .name(request.name())
                    .score(0)
                    .build());
        }

        QuizSession savedSession = quizSessionRepository.save(session);
        broadcastParticipants(savedSession);
        broadcastLeaderboard(savedSession);

        return toResponse(savedSession);
    }

    public void startSession(String code) {
        QuizSession session = findSessionByCode(code);
        session.setActive(true);
        quizSessionRepository.save(session);

        broadcastQuestion(code, 0);
        log.info("Started live quiz session {}", code);
    }

    public void broadcastQuestion(String code, int questionIndex) {
        QuizSession session = findSessionByCode(code);
        if (!session.isActive()) {
            throw new BadRequestException("Session is not active yet: " + code);
        }

        if (questionIndex < 0 || questionIndex >= session.getQuestionIds().size()) {
            throw new BadRequestException("Question index out of range for session: " + code);
        }

        String questionId = session.getQuestionIds().get(questionIndex);
        Question question = questionRepository.findById(questionId)
                .orElseThrow(() -> new ResourceNotFoundException("Question not found: " + questionId));

        QuizQuestionResponse response = new QuizQuestionResponse(
                question.getId(),
                question.getQuestion(),
                question.getOptions(),
                question.getDifficulty()
        );

        messagingTemplate.convertAndSend(topicQuestion(code.toUpperCase(Locale.ROOT)), response);
    }

    public List<QuizSession.LeaderboardEntry> submitAnswer(LiveAnswerRequest request) {
        QuizSession session = findSessionByCode(request.code());
        Question question = questionRepository.findById(request.questionId())
                .orElseThrow(() -> new ResourceNotFoundException("Question not found: " + request.questionId()));

        boolean isCorrect = normalize(question.getCorrectAnswer()).equals(normalize(request.answer()));
        if (isCorrect) {
            increaseScore(session, request.userId(), 10);
        }

        sortLeaderboard(session);
        QuizSession savedSession = quizSessionRepository.save(session);
        broadcastLeaderboard(savedSession);

        return savedSession.getLeaderboard();
    }

    private void increaseScore(QuizSession session, String userId, int points) {
        session.getParticipants().stream()
                .filter(participant -> participant.getUserId().equals(userId))
                .findFirst()
                .ifPresent(participant -> participant.setScore(participant.getScore() + points));

        session.getLeaderboard().stream()
                .filter(entry -> entry.getUserId().equals(userId))
                .findFirst()
                .ifPresent(entry -> entry.setScore(entry.getScore() + points));
    }

    private void sortLeaderboard(QuizSession session) {
        session.getLeaderboard().sort(Comparator.comparingInt(QuizSession.LeaderboardEntry::getScore).reversed());
    }

    private void broadcastParticipants(QuizSession session) {
        messagingTemplate.convertAndSend(topicParticipants(session.getCode()), session.getParticipants());
    }

    private void broadcastLeaderboard(QuizSession session) {
        sortLeaderboard(session);
        messagingTemplate.convertAndSend(topicLeaderboard(session.getCode()), session.getLeaderboard());
    }

    private String topicQuestion(String code) {
        return "/topic/live/" + code + "/question";
    }

    private String topicParticipants(String code) {
        return "/topic/live/" + code + "/participants";
    }

    private String topicLeaderboard(String code) {
        return "/topic/live/" + code + "/leaderboard";
    }

    private QuizSession findSessionByCode(String code) {
        return quizSessionRepository.findByCode(code.toUpperCase(Locale.ROOT))
                .orElseThrow(() -> new ResourceNotFoundException("Live session not found for code: " + code));
    }

    private String generateUniqueCode() {
        for (int attempt = 0; attempt < 10; attempt++) {
            StringBuilder codeBuilder = new StringBuilder();
            for (int i = 0; i < 6; i++) {
                codeBuilder.append(CODE_CHARACTERS.charAt(secureRandom.nextInt(CODE_CHARACTERS.length())));
            }

            String code = codeBuilder.toString();
            if (quizSessionRepository.findByCode(code).isEmpty()) {
                return code;
            }
        }

        throw new IllegalStateException("Unable to generate unique live quiz code");
    }

    private LiveSessionResponse toResponse(QuizSession session) {
        sortLeaderboard(session);
        return new LiveSessionResponse(
                session.getId(),
                session.getCode(),
                session.getParticipants().size(),
                session.getLeaderboard()
        );
    }

    private String normalize(String value) {
        return value == null ? "" : value.trim().toLowerCase(Locale.ROOT);
    }
}
