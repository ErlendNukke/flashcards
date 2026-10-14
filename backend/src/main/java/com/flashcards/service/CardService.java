package com.flashcards.service;

import com.flashcards.domain.FlashCard;
import com.flashcards.domain.FlashCardRepository;
import com.flashcards.web.dto.CardRequest;
import com.flashcards.web.dto.CardResponse;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.UUID;

@Service
public class CardService {

    private final FlashCardRepository repository;

    public CardService(FlashCardRepository repository) {
        this.repository = repository;
    }

    @Transactional(readOnly = true)
    public List<CardResponse> listForDevice(String deviceId) {
        return repository.findByDeviceIdOrderByCreatedAtAsc(deviceId).stream()
                .map(CardResponse::from)
                .toList();
    }

    @Transactional(readOnly = true)
    public CardResponse getForDevice(UUID id, String deviceId) {
        return CardResponse.from(requireOwned(id, deviceId));
    }

    @Transactional
    public CardResponse create(String deviceId, CardRequest request) {
        FlashCard card = new FlashCard(deviceId, request.question().trim(), request.answer().trim());
        return CardResponse.from(repository.save(card));
    }

    @Transactional
    public CardResponse update(UUID id, String deviceId, CardRequest request) {
        FlashCard card = requireOwned(id, deviceId);
        card.setQuestion(request.question().trim());
        card.setAnswer(request.answer().trim());
        return CardResponse.from(repository.save(card));
    }

    @Transactional
    public void delete(UUID id, String deviceId) {
        FlashCard card = requireOwned(id, deviceId);
        repository.delete(card);
    }

    private FlashCard requireOwned(UUID id, String deviceId) {
        return repository.findByIdAndDeviceId(id, deviceId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Card not found"));
    }
}
