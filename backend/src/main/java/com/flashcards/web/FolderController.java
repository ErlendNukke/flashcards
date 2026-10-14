package com.flashcards.web;

import com.flashcards.service.FolderService;
import com.flashcards.web.dto.FolderRequest;
import com.flashcards.web.dto.FolderResponse;
import com.flashcards.web.dto.LibrarySummaryResponse;
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

import java.util.UUID;

@RestController
@RequestMapping("/api/folders")
public class FolderController {

    private final FolderService folderService;

    public FolderController(FolderService folderService) {
        this.folderService = folderService;
    }

    @GetMapping
    public LibrarySummaryResponse list(
            @RequestHeader(value = CardController.DEVICE_ID_HEADER, required = false) String deviceId
    ) {
        return folderService.librarySummary(CardController.requireDeviceId(deviceId));
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public FolderResponse create(
            @RequestHeader(value = CardController.DEVICE_ID_HEADER, required = false) String deviceId,
            @Valid @RequestBody FolderRequest request
    ) {
        return folderService.create(CardController.requireDeviceId(deviceId), request);
    }

    @PutMapping("/{id}")
    public FolderResponse rename(
            @PathVariable UUID id,
            @RequestHeader(value = CardController.DEVICE_ID_HEADER, required = false) String deviceId,
            @Valid @RequestBody FolderRequest request
    ) {
        return folderService.rename(id, CardController.requireDeviceId(deviceId), request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(
            @PathVariable UUID id,
            @RequestHeader(value = CardController.DEVICE_ID_HEADER, required = false) String deviceId
    ) {
        folderService.delete(id, CardController.requireDeviceId(deviceId));
    }
}
