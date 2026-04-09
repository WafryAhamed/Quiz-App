package lk.edu.quizapp.service;

import lk.edu.quizapp.config.JwtService;
import lk.edu.quizapp.domain.User;
import lk.edu.quizapp.domain.UserRole;
import lk.edu.quizapp.dto.auth.AuthResponse;
import lk.edu.quizapp.dto.auth.LoginRequest;
import lk.edu.quizapp.dto.auth.RegisterRequest;
import lk.edu.quizapp.exception.BadRequestException;
import lk.edu.quizapp.exception.ResourceNotFoundException;
import lk.edu.quizapp.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.Instant;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;

    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.email())) {
            throw new BadRequestException("Email already exists: " + request.email());
        }

        UserRole role = parseRole(request.role());

        User user = User.builder()
                .name(request.name())
                .email(request.email().toLowerCase().trim())
                .password(passwordEncoder.encode(request.password()))
                .role(role)
                .createdAt(Instant.now())
                .build();

        User savedUser = userRepository.save(user);
        log.info("Registered new {} user: {}", savedUser.getRole(), savedUser.getEmail());

        return buildAuthResponse(savedUser);
    }

    public AuthResponse login(LoginRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.email().toLowerCase().trim(), request.password())
        );

        User user = userRepository.findByEmail(request.email().toLowerCase().trim())
                .orElseThrow(() -> new ResourceNotFoundException("User not found with email: " + request.email()));

        log.info("User logged in: {}", user.getEmail());
        return buildAuthResponse(user);
    }

    private AuthResponse buildAuthResponse(User user) {
        String jwtToken = jwtService.generateToken(user);
        return new AuthResponse(
                jwtToken,
                user.getId(),
                user.getName(),
                user.getEmail(),
                user.getRole().name().toLowerCase()
        );
    }

    private UserRole parseRole(String roleValue) {
        if (roleValue == null) {
            throw new BadRequestException("Role is required. Use student or lecturer.");
        }

        return switch (roleValue.trim().toLowerCase()) {
            case "student" -> UserRole.STUDENT;
            case "lecturer" -> UserRole.LECTURER;
            default -> throw new BadRequestException("Invalid role. Use student or lecturer.");
        };
    }
}
