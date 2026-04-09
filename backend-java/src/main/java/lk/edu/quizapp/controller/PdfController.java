package lk.edu.quizapp.controller;

import lk.edu.quizapp.dto.pdf.PdfUploadResponse;
import lk.edu.quizapp.service.PdfService;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/pdf")
@RequiredArgsConstructor
public class PdfController {

    private final PdfService pdfService;

    @PostMapping(value = "/upload", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<PdfUploadResponse> uploadPdf(@RequestPart("file") MultipartFile file,
                                                       Authentication authentication) {
        String userEmail = authentication.getName();
        PdfUploadResponse response = pdfService.uploadAndGenerateQuiz(file, userEmail);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/files/{fileName:.+}")
    public ResponseEntity<Resource> viewUploadedPdf(@PathVariable String fileName) {
        Resource resource = pdfService.loadFileAsResource(fileName);
        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_PDF)
                .body(resource);
    }
}
