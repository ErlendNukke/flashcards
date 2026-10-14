package com.flashcards.domain;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface FolderRepository extends JpaRepository<Folder, UUID> {

    List<Folder> findByUserIdOrderByNameAsc(UUID userId);

    Optional<Folder> findByIdAndUserId(UUID id, UUID userId);

    boolean existsByUserIdAndNameIgnoreCase(UUID userId, String name);

    List<Folder> findByDeviceIdAndUserIdIsNull(String deviceId);

    Optional<Folder> findByUserIdAndNameIgnoreCase(UUID userId, String name);

    @Query("SELECT COUNT(c) FROM FlashCard c WHERE c.userId = :userId AND c.folderId IS NULL")
    long countUnfiledByUserId(@Param("userId") UUID userId);
}
