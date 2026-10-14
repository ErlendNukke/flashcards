package com.flashcards.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "folder")
public class Folder {

    @Id
    private UUID id;

    @Column(name = "device_id", length = 64)
    private String deviceId;

    @Column(name = "user_id")
    private UUID userId;

    @Column(nullable = false, length = 120)
    private String name;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    protected Folder() {
    }

    public Folder(String deviceId, String name) {
        this.id = UUID.randomUUID();
        this.deviceId = deviceId;
        this.name = name;
    }

    public Folder(UUID userId, String name) {
        this.id = UUID.randomUUID();
        this.userId = userId;
        this.name = name;
    }

    @PrePersist
    void onCreate() {
        Instant now = Instant.now();
        if (createdAt == null) {
            createdAt = now;
        }
        updatedAt = now;
    }

    @PreUpdate
    void onUpdate() {
        updatedAt = Instant.now();
    }

    public UUID getId() {
        return id;
    }

    public String getDeviceId() {
        return deviceId;
    }

    public UUID getUserId() {
        return userId;
    }

    public void setUserId(UUID userId) {
        this.userId = userId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }
}
