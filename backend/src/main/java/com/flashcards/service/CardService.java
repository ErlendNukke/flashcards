package com.flashcards.service;

import com.flashcards.domain.FlashCard;
import com.flashcards.domain.FlashCardRepository;
import com.flashcards.web.dto.BulkActionResponse;
import com.flashcards.web.dto.BulkCardIdsRequest;
import com.flashcards.web.dto.BulkMoveRequest;
import com.flashcards.web.dto.CardRequest;
import com.flashcards.web.dto.CardResponse;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;

@Service
public class CardService {

    private final FlashCardRepository repository;
    private final FolderService folderService;

    public CardService(FlashCardRepository repository, FolderService folderService) {
        this.repository = repository;
        this.folderService = folderService;
    }

    @Transactional(readOnly = true)
    public List<CardResponse> listForDevice(String deviceId, UUID folderId, Boolean unfiled) {
        List<FlashCard> cards;
        if (Boolean.TRUE.equals(unfiled)) {
            cards = repository.findByDeviceIdAndFolderIdIsNullOrderByCreatedAtAsc(deviceId);
        } else if (folderId != null) {
            folderService.requireOwned(folderId, deviceId);
            cards = repository.findByDeviceIdAndFolderIdOrderByCreatedAtAsc(deviceId, folderId);
        } else {
            cards = repository.findByDeviceIdOrderByCreatedAtAsc(deviceId);
        }
        return cards.stream().map(CardResponse::from).toList();
    }

    @Transactional(readOnly = true)
    public CardResponse getForDevice(UUID id, String deviceId) {
        return CardResponse.from(requireOwned(id, deviceId));
    }

    @Transactional
    public CardResponse create(String deviceId, CardRequest request) {
        FlashCard card = new FlashCard(deviceId, request.question().trim(), request.answer().trim());
        card.setFolderId(resolveFolderId(deviceId, request.folderId()));
        return CardResponse.from(repository.save(card));
    }

    @Transactional
    public CardResponse update(UUID id, String deviceId, CardRequest request) {
        FlashCard card = requireOwned(id, deviceId);
        card.setQuestion(request.question().trim());
        card.setAnswer(request.answer().trim());
        card.setFolderId(resolveFolderId(deviceId, request.folderId()));
        return CardResponse.from(repository.save(card));
    }

    @Transactional
    public void delete(UUID id, String deviceId) {
        FlashCard card = requireOwned(id, deviceId);
        repository.delete(card);
    }

    @Transactional
    public BulkActionResponse bulkDelete(String deviceId, BulkCardIdsRequest request) {
        List<FlashCard> cards = loadAllRequested(deviceId, request.ids());
        repository.deleteAll(cards);
        return new BulkActionResponse(cards.size());
    }

    @Transactional
    public BulkActionResponse bulkMove(String deviceId, BulkMoveRequest request) {
        UUID folderId = request.folderId();
        if (folderId != null) {
            folderService.requireOwned(folderId, deviceId);
        }
        List<FlashCard> cards = loadAllRequested(deviceId, request.ids());
        for (FlashCard card : cards) {
            card.setFolderId(folderId);
        }
        repository.saveAll(cards);
        return new BulkActionResponse(cards.size());
    }

    private List<FlashCard> loadAllRequested(String deviceId, List<UUID> ids) {
        Set<UUID> unique = new HashSet<>(ids);
        List<FlashCard> cards = repository.findByDeviceIdAndIdIn(deviceId, unique);
        if (cards.size() != unique.size()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "One or more cards were not found");
        }
        return cards;
    }

    private UUID resolveFolderId(String deviceId, UUID folderId) {
        if (folderId == null) {
            return null;
        }
        folderService.requireOwned(folderId, deviceId);
        return folderId;
    }

    private FlashCard requireOwned(UUID id, String deviceId) {
        return repository.findByIdAndDeviceId(id, deviceId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Card not found"));
    }
}
