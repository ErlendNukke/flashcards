package com.flashcards.web.dto;

import com.flashcards.domain.FlashCard;

import java.time.Instant;
import java.util.UUID;

public record CardResponse(
        UUID id,
        String question,
        String answer,
        Instant createdAt,
        Instant updatedAt
) {
    public static CardResponse from(FlashCard card) {
        return new CardResponse(
                card.getId(),
                card.getQuestion(),
                card.getAnswer(),
                card.getCreatedAt(),
                card.getUpdatedAt()
        );
    }
}
