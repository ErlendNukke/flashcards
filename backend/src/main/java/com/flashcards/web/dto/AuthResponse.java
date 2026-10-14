package com.flashcards.web.dto;

public record AuthResponse(String token, UserResponse user) {
}
