package com.flashcards.domain;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface FlashCardRepository extends JpaRepository<FlashCard, UUID> {

    List<FlashCard> findByUserIdOrderByCreatedAtAsc(UUID userId);

    List<FlashCard> findByUserIdAndFolderIdOrderByCreatedAtAsc(UUID userId, UUID folderId);

    List<FlashCard> findByUserIdAndFolderIdIsNullOrderByCreatedAtAsc(UUID userId);

    long countByUserIdAndFolderId(UUID userId, UUID folderId);

    List<FlashCard> findByUserIdAndIdIn(UUID userId, Collection<UUID> ids);

    Optional<FlashCard> findByIdAndUserId(UUID id, UUID userId);

    List<FlashCard> findByDeviceIdAndFolderIdOrderByCreatedAtAsc(String deviceId, UUID folderId);

    List<FlashCard> findByDeviceIdAndUserIdIsNull(String deviceId);
}
