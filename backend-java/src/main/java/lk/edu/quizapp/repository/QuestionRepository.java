package lk.edu.quizapp.repository;

import lk.edu.quizapp.domain.Question;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;

public interface QuestionRepository extends MongoRepository<Question, String> {

    List<Question> findByPdfId(String pdfId);
}
