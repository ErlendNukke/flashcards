package com.flashcards.web.dto;

import com.flashcards.domain.AppUser;

import java.util.UUID;

public record UserResponse(UUID id, String username) {
    public static UserResponse from(AppUser user) {
        return new UserResponse(user.getId(), user.getUsername());
    }
}
