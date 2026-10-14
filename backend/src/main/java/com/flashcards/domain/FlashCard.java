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
@Table(name = "flash_card")
public class FlashCard {

    @Id
    private UUID id;

    @Column(name = "device_id", length = 64)
    private String deviceId;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String question;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String answer;

    @Column(name = "folder_id")
    private UUID folderId;

    @Column(name = "user_id")
    private UUID userId;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    protected FlashCard() {
    }

    public FlashCard(String deviceId, String question, String answer) {
        this.id = UUID.randomUUID();
        this.deviceId = deviceId;
        this.question = question;
        this.answer = answer;
    }

    public FlashCard(UUID userId, String question, String answer) {
        this.id = UUID.randomUUID();
        this.userId = userId;
        this.question = question;
        this.answer = answer;
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

    public String getQuestion() {
        return question;
    }

    public void setQuestion(String question) {
        this.question = question;
    }

    public String getAnswer() {
        return answer;
    }

    public void setAnswer(String answer) {
        this.answer = answer;
    }

    public UUID getFolderId() {
        return folderId;
    }

    public void setFolderId(UUID folderId) {
        this.folderId = folderId;
    }

    public UUID getUserId() {
        return userId;
    }

    public void setUserId(UUID userId) {
        this.userId = userId;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }
}
