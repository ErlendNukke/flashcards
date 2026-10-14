package com.flashcards.web.dto;

import java.util.List;

public record LibrarySummaryResponse(
        List<FolderResponse> folders,
        long unfiledCount
) {
}
