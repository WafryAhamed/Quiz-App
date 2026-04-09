package lk.edu.quizapp.service;

import lk.edu.quizapp.domain.Question;
import lk.edu.quizapp.dto.quiz.QuizQuestionResponse;
import lk.edu.quizapp.dto.quiz.QuizSubmitRequest;
import lk.edu.quizapp.dto.quiz.QuizSubmitResponse;
import lk.edu.quizapp.exception.ResourceNotFoundException;
import lk.edu.quizapp.repository.QuestionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class QuizService {

    private final QuestionRepository questionRepository;

    public List<QuizQuestionResponse> getQuizByPdfId(String pdfId) {
        List<Question> questions = questionRepository.findByPdfId(pdfId);
        if (questions.isEmpty()) {
            throw new ResourceNotFoundException("No questions found for PDF ID: " + pdfId);
        }

        return questions.stream()
                .map(question -> new QuizQuestionResponse(
                        question.getId(),
                        question.getQuestion(),
                        question.getOptions(),
                        question.getDifficulty()
                ))
                .collect(Collectors.toList());
    }

    public QuizSubmitResponse submitQuiz(QuizSubmitRequest request) {
        List<Question> questions = questionRepository.findByPdfId(request.pdfId());
        if (questions.isEmpty()) {
            throw new ResourceNotFoundException("No questions found for PDF ID: " + request.pdfId());
        }

        Map<String, Question> questionMap = questions.stream()
                .collect(Collectors.toMap(Question::getId, q -> q));

        int correctAnswers = 0;
        Map<String, Boolean> perQuestionResult = new LinkedHashMap<>();

        for (QuizSubmitRequest.AnswerItem answerItem : request.answers()) {
            Question question = questionMap.get(answerItem.questionId());
            if (question == null) {
                perQuestionResult.put(answerItem.questionId(), false);
                continue;
            }

            boolean isCorrect = normalize(question.getCorrectAnswer()).equals(normalize(answerItem.answer()));
            perQuestionResult.put(answerItem.questionId(), isCorrect);
            if (isCorrect) {
                correctAnswers++;
            }
        }

        int totalSubmitted = request.answers().size();
        double scorePercentage = totalSubmitted == 0 ? 0 : (correctAnswers * 100.0) / totalSubmitted;

        return new QuizSubmitResponse(totalSubmitted, correctAnswers, scorePercentage, perQuestionResult);
    }

    private String normalize(String value) {
        return value == null ? "" : value.trim().toLowerCase();
    }
}
