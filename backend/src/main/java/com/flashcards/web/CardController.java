package com.flashcards.web;

import com.flashcards.service.CardService;
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
    public List<CardResponse> list(@RequestHeader(value = DEVICE_ID_HEADER, required = false) String deviceId) {
        return cardService.listForDevice(requireDeviceId(deviceId));
    }

    @GetMapping("/{id}")
    public CardResponse get(
            @PathVariable UUID id,
            @RequestHeader(value = DEVICE_ID_HEADER, required = false) String deviceId
    ) {
        return cardService.getForDevice(id, requireDeviceId(deviceId));
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public CardResponse create(
            @RequestHeader(value = DEVICE_ID_HEADER, required = false) String deviceId,
            @Valid @RequestBody CardRequest request
    ) {
        return cardService.create(requireDeviceId(deviceId), request);
    }

    @PutMapping("/{id}")
    public CardResponse update(
            @PathVariable UUID id,
            @RequestHeader(value = DEVICE_ID_HEADER, required = false) String deviceId,
            @Valid @RequestBody CardRequest request
    ) {
        return cardService.update(id, requireDeviceId(deviceId), request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(
            @PathVariable UUID id,
            @RequestHeader(value = DEVICE_ID_HEADER, required = false) String deviceId
    ) {
        cardService.delete(id, requireDeviceId(deviceId));
    }

    static String requireDeviceId(String deviceId) {
        if (deviceId == null || deviceId.isBlank()) {
            throw new IllegalArgumentException("Missing X-Device-Id header");
        }
        String trimmed = deviceId.trim();
        if (trimmed.length() > 64) {
            throw new IllegalArgumentException("X-Device-Id must be at most 64 characters");
        }
        return trimmed;
    }
}
