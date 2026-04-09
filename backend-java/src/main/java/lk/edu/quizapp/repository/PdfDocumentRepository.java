package lk.edu.quizapp.repository;

import lk.edu.quizapp.domain.PdfDocument;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;

public interface PdfDocumentRepository extends MongoRepository<PdfDocument, String> {

    List<PdfDocument> findByUserId(String userId);
}
