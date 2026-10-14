package com.flashcards.service;

import com.flashcards.domain.FlashCard;
import com.flashcards.domain.FlashCardRepository;
import com.flashcards.domain.Folder;
import com.flashcards.domain.FolderRepository;
import com.flashcards.web.dto.FolderRequest;
import com.flashcards.web.dto.FolderResponse;
import com.flashcards.web.dto.LibrarySummaryResponse;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.UUID;

@Service
public class FolderService {

    private final FolderRepository folderRepository;
    private final FlashCardRepository cardRepository;

    public FolderService(FolderRepository folderRepository, FlashCardRepository cardRepository) {
        this.folderRepository = folderRepository;
        this.cardRepository = cardRepository;
    }

    @Transactional(readOnly = true)
    public LibrarySummaryResponse librarySummary(UUID userId) {
        List<FolderResponse> folders = folderRepository.findByUserIdOrderByNameAsc(userId).stream()
                .map(f -> FolderResponse.from(f, cardRepository.countByUserIdAndFolderId(userId, f.getId())))
                .toList();
        long unfiled = folderRepository.countUnfiledByUserId(userId);
        return new LibrarySummaryResponse(folders, unfiled);
    }

    @Transactional
    public FolderResponse create(UUID userId, FolderRequest request) {
        String name = FolderNameValidator.normalize(request.name());
        if (folderRepository.existsByUserIdAndNameIgnoreCase(userId, name)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "A folder with this name already exists");
        }
        return FolderResponse.from(folderRepository.save(new Folder(userId, name)), 0);
    }

    @Transactional
    public FolderResponse rename(UUID id, UUID userId, FolderRequest request) {
        Folder folder = requireOwned(id, userId);
        String name = FolderNameValidator.normalize(request.name());
        if (!folder.getName().equalsIgnoreCase(name)
                && folderRepository.existsByUserIdAndNameIgnoreCase(userId, name)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "A folder with this name already exists");
        }
        folder.setName(name);
        long count = cardRepository.countByUserIdAndFolderId(userId, folder.getId());
        return FolderResponse.from(folderRepository.save(folder), count);
    }

    @Transactional
    public void delete(UUID id, UUID userId) {
        Folder folder = requireOwned(id, userId);
        List<FlashCard> cards = cardRepository.findByUserIdAndFolderIdOrderByCreatedAtAsc(userId, id);
        for (FlashCard card : cards) {
            card.setFolderId(null);
        }
        cardRepository.saveAll(cards);
        folderRepository.delete(folder);
    }

    @Transactional(readOnly = true)
    public Folder requireOwned(UUID id, UUID userId) {
        return folderRepository.findByIdAndUserId(id, userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Folder not found"));
    }
}
