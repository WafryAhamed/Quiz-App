package lk.edu.quizapp.service;

import jakarta.annotation.PostConstruct;
import lk.edu.quizapp.domain.PdfDocument;
import lk.edu.quizapp.domain.Question;
import lk.edu.quizapp.domain.User;
import lk.edu.quizapp.dto.ai.AIQuestionDto;
import lk.edu.quizapp.dto.ai.AIQuizResponse;
import lk.edu.quizapp.dto.pdf.PdfUploadResponse;
import lk.edu.quizapp.exception.BadRequestException;
import lk.edu.quizapp.exception.ResourceNotFoundException;
import lk.edu.quizapp.repository.PdfDocumentRepository;
import lk.edu.quizapp.repository.QuestionRepository;
import lk.edu.quizapp.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.net.MalformedURLException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Optional;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class PdfService {

    private final PdfDocumentRepository pdfDocumentRepository;
    private final QuestionRepository questionRepository;
    private final UserRepository userRepository;
    private final AIQuizClientService aiQuizClientService;

    @Value("${app.storage.upload-dir}")
    private String uploadDir;

    private Path uploadPath;

    @PostConstruct
    public void initStorage() {
        try {
            this.uploadPath = Paths.get(uploadDir).toAbsolutePath().normalize();
            Files.createDirectories(this.uploadPath);
            log.info("PDF upload directory initialized at {}", this.uploadPath);
        } catch (IOException ex) {
            throw new IllegalStateException("Unable to initialize upload directory", ex);
        }
    }

    public PdfUploadResponse uploadAndGenerateQuiz(MultipartFile file, String userEmail) {
        validatePdf(file);

        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new ResourceNotFoundException("User not found for email: " + userEmail));

        String originalFileName = Optional.ofNullable(file.getOriginalFilename()).orElse("lecture-material.pdf");
        String safeFileName = originalFileName.replaceAll("[^a-zA-Z0-9._-]", "_");
        String storedFileName = UUID.randomUUID() + "-" + safeFileName;

        try {
            Path destination = uploadPath.resolve(storedFileName).normalize();
            if (!destination.startsWith(uploadPath)) {
                throw new BadRequestException("Invalid file path");
            }

            Files.write(destination, file.getBytes(), StandardOpenOption.CREATE_NEW);

            PdfDocument pdfDocument = PdfDocument.builder()
                    .userId(user.getId())
                    .fileUrl("/pdf/files/" + storedFileName)
                    .uploadedAt(Instant.now())
                    .originalFileName(originalFileName)
                    .build();

            PdfDocument savedPdf = pdfDocumentRepository.save(pdfDocument);

            int generatedQuestionCount = generateAndSaveQuestions(savedPdf.getId(), file);
            log.info("Uploaded PDF {} and generated {} questions", savedPdf.getId(), generatedQuestionCount);

            return new PdfUploadResponse(
                    savedPdf.getId(),
                    savedPdf.getFileUrl(),
                    savedPdf.getUploadedAt(),
                    generatedQuestionCount
            );
        } catch (IOException ex) {
            throw new BadRequestException("Failed to store PDF file: " + ex.getMessage());
        }
    }

    public Resource loadFileAsResource(String fileName) {
        try {
            Path path = uploadPath.resolve(fileName).normalize();
            if (!path.startsWith(uploadPath)) {
                throw new BadRequestException("Invalid file path");
            }

            Resource resource = new UrlResource(path.toUri());
            if (!resource.exists() || !resource.isReadable()) {
                throw new ResourceNotFoundException("File not found: " + fileName);
            }

            return resource;
        } catch (MalformedURLException ex) {
            throw new BadRequestException("Invalid file URL: " + ex.getMessage());
        }
    }

    private int generateAndSaveQuestions(String pdfId, MultipartFile file) {
        try {
            AIQuizResponse response = aiQuizClientService.generateQuizFromPdf(file);
            List<Question> questions = new ArrayList<>();

            for (AIQuestionDto aiQuestion : response.questions()) {
                if (aiQuestion == null || aiQuestion.question() == null || aiQuestion.options() == null || aiQuestion.options().isEmpty()) {
                    continue;
                }

                Question question = Question.builder()
                        .pdfId(pdfId)
                        .question(aiQuestion.question())
                        .options(aiQuestion.options())
                        .correctAnswer(aiQuestion.correctAnswer())
                        .difficulty(Optional.ofNullable(aiQuestion.difficulty()).orElse("medium").toLowerCase(Locale.ROOT))
                        .build();
                questions.add(question);
            }

            if (!questions.isEmpty()) {
                questionRepository.saveAll(questions);
            }

            return questions.size();
        } catch (Exception ex) {
            log.error("Quiz generation failed for PDF {}: {}", pdfId, ex.getMessage());
            return 0;
        }
    }

    private void validatePdf(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new BadRequestException("PDF file is required");
        }

        String fileName = Optional.ofNullable(file.getOriginalFilename()).orElse("").toLowerCase(Locale.ROOT);
        if (!fileName.endsWith(".pdf")) {
            throw new BadRequestException("Only PDF files are allowed");
        }
    }
}
