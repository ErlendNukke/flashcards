package com.flashcards.service;

import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

public final class FolderNameValidator {

    public static final int MAX_LENGTH = 120;

    private FolderNameValidator() {
    }

    public static String normalize(String raw) {
        if (raw == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Folder name is required");
        }
        String trimmed = raw.trim();
        if (trimmed.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Folder name cannot be empty");
        }
        if (trimmed.length() > MAX_LENGTH) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Folder name must be at most " + MAX_LENGTH + " characters");
        }
        return trimmed;
    }
}
