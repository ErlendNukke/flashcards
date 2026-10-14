package com.flashcards.web.dto;

import com.flashcards.domain.Folder;

import java.time.Instant;
import java.util.UUID;

public record FolderResponse(
        UUID id,
        String name,
        long cardCount,
        Instant createdAt,
        Instant updatedAt
) {
    public static FolderResponse from(Folder folder, long cardCount) {
        return new FolderResponse(
                folder.getId(),
                folder.getName(),
                cardCount,
                folder.getCreatedAt(),
                folder.getUpdatedAt()
        );
    }
}
