package com.flashcards.web.dto;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;

import java.util.List;
import java.util.UUID;

public record BulkMoveRequest(
        @NotEmpty List<@NotNull UUID> ids,
        UUID folderId
) {
}
