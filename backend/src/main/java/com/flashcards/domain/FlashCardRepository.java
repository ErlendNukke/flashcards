package com.flashcards.domain;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface FlashCardRepository extends JpaRepository<FlashCard, UUID> {

    List<FlashCard> findByDeviceIdOrderByCreatedAtAsc(String deviceId);

    List<FlashCard> findByDeviceIdAndFolderIdOrderByCreatedAtAsc(String deviceId, UUID folderId);

    List<FlashCard> findByDeviceIdAndFolderIdIsNullOrderByCreatedAtAsc(String deviceId);

    long countByDeviceIdAndFolderId(String deviceId, UUID folderId);

    List<FlashCard> findByDeviceIdAndIdIn(String deviceId, Collection<UUID> ids);

    Optional<FlashCard> findByIdAndDeviceId(UUID id, String deviceId);
}
