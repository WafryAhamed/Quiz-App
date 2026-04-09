package lk.edu.quizapp.repository;

import lk.edu.quizapp.domain.QuizSession;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.Optional;

public interface QuizSessionRepository extends MongoRepository<QuizSession, String> {

    Optional<QuizSession> findByCode(String code);
}
