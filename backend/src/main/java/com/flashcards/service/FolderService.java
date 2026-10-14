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
    public LibrarySummaryResponse librarySummary(String deviceId) {
        List<FolderResponse> folders = folderRepository.findByDeviceIdOrderByNameAsc(deviceId).stream()
                .map(f -> FolderResponse.from(f, cardRepository.countByDeviceIdAndFolderId(deviceId, f.getId())))
                .toList();
        long unfiled = folderRepository.countUnfiledByDeviceId(deviceId);
        return new LibrarySummaryResponse(folders, unfiled);
    }

    @Transactional
    public FolderResponse create(String deviceId, FolderRequest request) {
        String name = FolderNameValidator.normalize(request.name());
        if (folderRepository.existsByDeviceIdAndNameIgnoreCase(deviceId, name)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "A folder with this name already exists");
        }
        return FolderResponse.from(folderRepository.save(new Folder(deviceId, name)), 0);
    }

    @Transactional
    public FolderResponse rename(UUID id, String deviceId, FolderRequest request) {
        Folder folder = requireOwned(id, deviceId);
        String name = FolderNameValidator.normalize(request.name());
        if (!folder.getName().equalsIgnoreCase(name)
                && folderRepository.existsByDeviceIdAndNameIgnoreCase(deviceId, name)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "A folder with this name already exists");
        }
        folder.setName(name);
        long count = cardRepository.countByDeviceIdAndFolderId(deviceId, folder.getId());
        return FolderResponse.from(folderRepository.save(folder), count);
    }

    /**
     * Deletes the folder and moves its cards to the unfiled bucket (folder_id = null).
     */
    @Transactional
    public void delete(UUID id, String deviceId) {
        Folder folder = requireOwned(id, deviceId);
        List<FlashCard> cards = cardRepository.findByDeviceIdAndFolderIdOrderByCreatedAtAsc(deviceId, id);
        for (FlashCard card : cards) {
            card.setFolderId(null);
        }
        cardRepository.saveAll(cards);
        folderRepository.delete(folder);
    }

    @Transactional(readOnly = true)
    public Folder requireOwned(UUID id, String deviceId) {
        return folderRepository.findByIdAndDeviceId(id, deviceId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Folder not found"));
    }
}
