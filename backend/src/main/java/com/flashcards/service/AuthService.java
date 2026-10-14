package com.flashcards.service;

import com.flashcards.domain.AppUser;
import com.flashcards.domain.AppUserRepository;
import com.flashcards.security.JwtService;
import com.flashcards.web.dto.AuthResponse;
import com.flashcards.web.dto.LoginRequest;
import com.flashcards.web.dto.RegisterRequest;
import com.flashcards.web.dto.UserResponse;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService {

    private final AppUserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final DeviceClaimService deviceClaimService;

    public AuthService(
            AppUserRepository userRepository,
            PasswordEncoder passwordEncoder,
            JwtService jwtService,
            DeviceClaimService deviceClaimService
    ) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.deviceClaimService = deviceClaimService;
    }

    @Transactional
    public AuthResponse register(RegisterRequest request, String deviceId) {
        String username = UsernameValidator.normalize(request.username());
        if (userRepository.existsByUsernameIgnoreCase(username)) {
            throw new IllegalArgumentException("Username already taken");
        }
        if (request.password() == null || request.password().length() < 8) {
            throw new IllegalArgumentException("Password must be at least 8 characters");
        }
        AppUser user = new AppUser(username, passwordEncoder.encode(request.password()));
        userRepository.save(user);
        deviceClaimService.claimDeviceData(user.getId(), deviceId);
        return toAuthResponse(user);
    }

    @Transactional
    public AuthResponse login(LoginRequest request, String deviceId) {
        String username = UsernameValidator.normalize(request.username());
        AppUser user = userRepository.findByUsernameIgnoreCase(username)
                .orElseThrow(() -> new IllegalArgumentException("Invalid username or password"));
        if (!passwordEncoder.matches(request.password(), user.getPasswordHash())) {
            throw new IllegalArgumentException("Invalid username or password");
        }
        deviceClaimService.claimDeviceData(user.getId(), deviceId);
        return toAuthResponse(user);
    }

    @Transactional(readOnly = true)
    public UserResponse me(AppUser user) {
        return UserResponse.from(user);
    }

    private AuthResponse toAuthResponse(AppUser user) {
        return new AuthResponse(jwtService.generateToken(user), UserResponse.from(user));
    }
}
