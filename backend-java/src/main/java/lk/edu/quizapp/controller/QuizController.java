package lk.edu.quizapp.controller;

import jakarta.validation.Valid;
import lk.edu.quizapp.dto.quiz.QuizQuestionResponse;
import lk.edu.quizapp.dto.quiz.QuizSubmitRequest;
import lk.edu.quizapp.dto.quiz.QuizSubmitResponse;
import lk.edu.quizapp.service.QuizService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/quiz")
@RequiredArgsConstructor
public class QuizController {

    private final QuizService quizService;

    @GetMapping("/{pdfId}")
    public ResponseEntity<List<QuizQuestionResponse>> getQuizByPdfId(@PathVariable String pdfId) {
        return ResponseEntity.ok(quizService.getQuizByPdfId(pdfId));
    }

    @PostMapping("/submit")
    public ResponseEntity<QuizSubmitResponse> submitQuiz(@Valid @RequestBody QuizSubmitRequest request) {
        return ResponseEntity.ok(quizService.submitQuiz(request));
    }
}
