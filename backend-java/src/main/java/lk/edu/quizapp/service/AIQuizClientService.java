package lk.edu.quizapp.service;

import lk.edu.quizapp.dto.ai.AIQuizResponse;
import lk.edu.quizapp.exception.BadRequestException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.MediaType;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.client.MultipartBodyBuilder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.io.IOException;
import java.time.Duration;

@Slf4j
@Service
@RequiredArgsConstructor
public class AIQuizClientService {

    private final WebClient webClient;

    @Value("${app.ai.service-url}")
    private String aiServiceUrl;

    public AIQuizResponse generateQuizFromPdf(MultipartFile file) {
        try {
            MultipartBodyBuilder multipartBodyBuilder = new MultipartBodyBuilder();
            multipartBodyBuilder.part("file", new ByteArrayResource(file.getBytes()) {
                @Override
                public String getFilename() {
                    return file.getOriginalFilename() != null ? file.getOriginalFilename() : "lecture-note.pdf";
                }
            }).contentType(MediaType.APPLICATION_PDF);

            AIQuizResponse response = webClient.post()
                    .uri(aiServiceUrl + "/generate-quiz")
                    .contentType(MediaType.MULTIPART_FORM_DATA)
                    .body(BodyInserters.fromMultipartData(multipartBodyBuilder.build()))
                    .retrieve()
                    .onStatus(HttpStatusCode::isError, clientResponse -> clientResponse.bodyToMono(String.class)
                            .flatMap(body -> Mono.error(new BadRequestException("AI service error: " + body))))
                    .bodyToMono(AIQuizResponse.class)
                    .block(Duration.ofSeconds(90));

            if (response == null || response.questions() == null || response.questions().isEmpty()) {
                throw new BadRequestException("AI service did not return quiz questions");
            }

            return response;
        } catch (IOException ex) {
            throw new BadRequestException("Failed to process uploaded PDF: " + ex.getMessage());
        } catch (Exception ex) {
            log.error("Failed to call AI service: {}", ex.getMessage());
            throw new BadRequestException("Unable to generate quiz from AI service: " + ex.getMessage());
        }
    }
}
