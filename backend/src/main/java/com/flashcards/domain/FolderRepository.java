package com.flashcards.domain;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface FolderRepository extends JpaRepository<Folder, UUID> {

    List<Folder> findByDeviceIdOrderByNameAsc(String deviceId);

    Optional<Folder> findByIdAndDeviceId(UUID id, String deviceId);

    boolean existsByDeviceIdAndNameIgnoreCase(String deviceId, String name);

    @Query("SELECT COUNT(c) FROM FlashCard c WHERE c.deviceId = :deviceId AND c.folderId IS NULL")
    long countUnfiledByDeviceId(@Param("deviceId") String deviceId);
}
