package lk.edu.quizapp.dto.pdf;

import java.time.Instant;

public record PdfUploadResponse(
        String pdfId,
        String fileUrl,
        Instant uploadedAt,
        int generatedQuestionCount
) {
}
