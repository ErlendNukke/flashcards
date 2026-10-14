package com.flashcards.service;

import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

import java.util.regex.Pattern;

public final class UsernameValidator {

    public static final int MIN_LENGTH = 3;
    public static final int MAX_LENGTH = 32;
    private static final Pattern ALLOWED = Pattern.compile("^[a-zA-Z0-9_]+$");

    private UsernameValidator() {
    }

    public static String normalize(String raw) {
        if (raw == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Username is required");
        }
        String trimmed = raw.trim();
        if (trimmed.length() < MIN_LENGTH || trimmed.length() > MAX_LENGTH) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Username must be " + MIN_LENGTH + "–" + MAX_LENGTH + " characters");
        }
        if (!ALLOWED.matcher(trimmed).matches()) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Username may only contain letters, numbers, and underscores");
        }
        return trimmed.toLowerCase();
    }
}
