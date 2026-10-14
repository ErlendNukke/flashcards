package com.flashcards.web;

import com.flashcards.domain.AppUser;
import com.flashcards.security.SecurityUtils;
import com.flashcards.service.AuthService;
import com.flashcards.web.dto.AuthResponse;
import com.flashcards.web.dto.LoginRequest;
import com.flashcards.web.dto.RegisterRequest;
import com.flashcards.web.dto.UserResponse;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/register")
    @ResponseStatus(HttpStatus.CREATED)
    public AuthResponse register(
            @Valid @RequestBody RegisterRequest request,
            @RequestHeader(value = CardController.DEVICE_ID_HEADER, required = false) String deviceId
    ) {
        return authService.register(request, CardController.optionalDeviceId(deviceId));
    }

    @PostMapping("/login")
    public AuthResponse login(
            @Valid @RequestBody LoginRequest request,
            @RequestHeader(value = CardController.DEVICE_ID_HEADER, required = false) String deviceId
    ) {
        return authService.login(request, CardController.optionalDeviceId(deviceId));
    }

    @GetMapping("/me")
    public UserResponse me() {
        AppUser user = SecurityUtils.requireCurrentUser();
        return authService.me(user);
    }
}
