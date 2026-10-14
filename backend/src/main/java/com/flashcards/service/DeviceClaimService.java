package com.flashcards.service;

import com.flashcards.domain.FlashCard;
import com.flashcards.domain.FlashCardRepository;
import com.flashcards.domain.Folder;
import com.flashcards.domain.FolderRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
public class DeviceClaimService {

    private final FolderRepository folderRepository;
    private final FlashCardRepository cardRepository;

    public DeviceClaimService(FolderRepository folderRepository, FlashCardRepository cardRepository) {
        this.folderRepository = folderRepository;
        this.cardRepository = cardRepository;
    }

    /**
     * Moves anonymous device-scoped folders and cards into the authenticated account.
     */
    @Transactional
    public void claimDeviceData(UUID userId, String deviceId) {
        if (deviceId == null || deviceId.isBlank()) {
            return;
        }
        String trimmedDevice = deviceId.trim();

        List<Folder> deviceFolders = folderRepository.findByDeviceIdAndUserIdIsNull(trimmedDevice);
        for (Folder folder : deviceFolders) {
            Optional<Folder> existing = folderRepository.findByUserIdAndNameIgnoreCase(userId, folder.getName());
            if (existing.isPresent()) {
                UUID targetFolderId = existing.get().getId();
                List<FlashCard> cards = cardRepository.findByDeviceIdAndFolderIdOrderByCreatedAtAsc(trimmedDevice, folder.getId());
                for (FlashCard card : cards) {
                    card.setUserId(userId);
                    card.setFolderId(targetFolderId);
                }
                cardRepository.saveAll(cards);
                folderRepository.delete(folder);
            } else {
                folder.setUserId(userId);
                folderRepository.save(folder);
            }
        }

        List<FlashCard> unclaimedCards = cardRepository.findByDeviceIdAndUserIdIsNull(trimmedDevice);
        for (FlashCard card : unclaimedCards) {
            card.setUserId(userId);
        }
        cardRepository.saveAll(unclaimedCards);
    }
}
