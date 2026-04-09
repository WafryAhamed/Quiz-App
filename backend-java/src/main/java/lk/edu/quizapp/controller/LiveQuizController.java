package lk.edu.quizapp.controller;

import jakarta.validation.Valid;
import lk.edu.quizapp.domain.QuizSession;
import lk.edu.quizapp.dto.live.LiveAnswerRequest;
import lk.edu.quizapp.dto.live.LiveCreateRequest;
import lk.edu.quizapp.dto.live.LiveJoinRequest;
import lk.edu.quizapp.dto.live.LiveSessionResponse;
import lk.edu.quizapp.service.LiveQuizService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/live")
@RequiredArgsConstructor
public class LiveQuizController {

    private final LiveQuizService liveQuizService;

    @PostMapping("/create")
    public ResponseEntity<LiveSessionResponse> createLiveQuiz(@Valid @RequestBody LiveCreateRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(liveQuizService.createSession(request));
    }

    @PostMapping("/join")
    public ResponseEntity<LiveSessionResponse> joinLiveQuiz(@Valid @RequestBody LiveJoinRequest request) {
        return ResponseEntity.ok(liveQuizService.joinSession(request));
    }

    @PostMapping("/start/{code}")
    public ResponseEntity<String> startLiveQuiz(@PathVariable String code) {
        liveQuizService.startSession(code);
        return ResponseEntity.ok("Live quiz started for code " + code.toUpperCase());
    }

    @PostMapping("/next/{code}/{index}")
    public ResponseEntity<String> broadcastNextQuestion(@PathVariable String code, @PathVariable int index) {
        liveQuizService.broadcastQuestion(code, index);
        return ResponseEntity.ok("Question " + index + " pushed to participants");
    }

    @PostMapping("/answer")
    public ResponseEntity<List<QuizSession.LeaderboardEntry>> submitLiveAnswer(@Valid @RequestBody LiveAnswerRequest request) {
        return ResponseEntity.ok(liveQuizService.submitAnswer(request));
    }
}
