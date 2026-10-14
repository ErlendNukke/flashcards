package com.flashcards.web;

import com.flashcards.domain.AppUser;
import com.flashcards.security.SecurityUtils;
import com.flashcards.service.CardService;
import com.flashcards.web.dto.BulkActionResponse;
import com.flashcards.web.dto.BulkCardIdsRequest;
import com.flashcards.web.dto.BulkMoveRequest;
import com.flashcards.web.dto.CardRequest;
import com.flashcards.web.dto.CardResponse;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/cards")
public class CardController {

    public static final String DEVICE_ID_HEADER = "X-Device-Id";

    private final CardService cardService;

    public CardController(CardService cardService) {
        this.cardService = cardService;
    }

    @GetMapping
    public List<CardResponse> list(
            @RequestParam(required = false) UUID folderId,
            @RequestParam(required = false) Boolean unfiled
    ) {
        AppUser user = SecurityUtils.requireCurrentUser();
        return cardService.listForUser(user.getId(), folderId, unfiled);
    }

    @GetMapping("/{id}")
    public CardResponse get(@PathVariable UUID id) {
        AppUser user = SecurityUtils.requireCurrentUser();
        return cardService.getForUser(id, user.getId());
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public CardResponse create(@Valid @RequestBody CardRequest request) {
        AppUser user = SecurityUtils.requireCurrentUser();
        return cardService.create(user.getId(), request);
    }

    @PutMapping("/{id}")
    public CardResponse update(@PathVariable UUID id, @Valid @RequestBody CardRequest request) {
        AppUser user = SecurityUtils.requireCurrentUser();
        return cardService.update(id, user.getId(), request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable UUID id) {
        AppUser user = SecurityUtils.requireCurrentUser();
        cardService.delete(id, user.getId());
    }

    @PostMapping("/bulk-delete")
    public BulkActionResponse bulkDelete(@Valid @RequestBody BulkCardIdsRequest request) {
        AppUser user = SecurityUtils.requireCurrentUser();
        return cardService.bulkDelete(user.getId(), request);
    }

    @PostMapping("/bulk-move")
    public BulkActionResponse bulkMove(@Valid @RequestBody BulkMoveRequest request) {
        AppUser user = SecurityUtils.requireCurrentUser();
        return cardService.bulkMove(user.getId(), request);
    }

    static String optionalDeviceId(String deviceId) {
        if (deviceId == null || deviceId.isBlank()) {
            return null;
        }
        String trimmed = deviceId.trim();
        if (trimmed.length() > 64) {
            throw new IllegalArgumentException("X-Device-Id must be at most 64 characters");
        }
        return trimmed;
    }
}
