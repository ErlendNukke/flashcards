package com.flashcards.web.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CardRequest(
        @NotBlank @Size(max = 4000) String question,
        @NotBlank @Size(max = 4000) String answer
) {
}
