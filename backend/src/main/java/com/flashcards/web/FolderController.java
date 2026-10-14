package com.flashcards.web;

import com.flashcards.domain.AppUser;
import com.flashcards.security.SecurityUtils;
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
    public LibrarySummaryResponse list() {
        AppUser user = SecurityUtils.requireCurrentUser();
        return folderService.librarySummary(user.getId());
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public FolderResponse create(@Valid @RequestBody FolderRequest request) {
        AppUser user = SecurityUtils.requireCurrentUser();
        return folderService.create(user.getId(), request);
    }

    @PutMapping("/{id}")
    public FolderResponse rename(@PathVariable UUID id, @Valid @RequestBody FolderRequest request) {
        AppUser user = SecurityUtils.requireCurrentUser();
        return folderService.rename(id, user.getId(), request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable UUID id) {
        AppUser user = SecurityUtils.requireCurrentUser();
        folderService.delete(id, user.getId());
    }
}
