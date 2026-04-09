package lk.edu.quizapp.domain;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "pdfs")
public class PdfDocument {

    @Id
    private String id;

    private String userId;
    private String fileUrl;
    private Instant uploadedAt;
    private String originalFileName;
}
