package com.flashcards.web;

import com.flashcards.domain.FlashCard;
import com.flashcards.domain.FlashCardRepository;
import com.flashcards.domain.Folder;
import com.flashcards.domain.FolderRepository;
import com.flashcards.support.AuthTestSupport;
import com.flashcards.support.IntegrationTestBase;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Map;
import java.util.UUID;

import static org.hamcrest.Matchers.hasSize;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@AutoConfigureMockMvc
class DeviceClaimIntegrationTest extends IntegrationTestBase {

    @Autowired
    MockMvc mvc;

    @Autowired
    FolderRepository folderRepository;

    @Autowired
    FlashCardRepository cardRepository;

    @Test
    void registerClaimsAnonymousDeviceData() throws Exception {
        String deviceId = UUID.randomUUID().toString();

        Folder folder = folderRepository.save(new Folder(deviceId, "Biology"));
        FlashCard card = new FlashCard(deviceId, "Q?", "A!");
        card.setFolderId(folder.getId());
        cardRepository.save(card);
        cardRepository.save(new FlashCard(deviceId, "Unfiled?", "Yes"));

        String username = "claim_" + UUID.randomUUID().toString().substring(0, 8);
        var registerResult = mvc.perform(post("/api/auth/register")
                        .header(CardController.DEVICE_ID_HEADER, deviceId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(JSON.writeValueAsString(Map.of(
                                "username", username,
                                "password", "password123"
                        ))))
                .andExpect(status().isCreated())
                .andReturn();

        String userId = JSON.readTree(registerResult.getResponse().getContentAsString())
                .get("user").get("id").asText();
        String token = JSON.readTree(registerResult.getResponse().getContentAsString())
                .get("token").asText();

        assertEquals(2, cardRepository.findByUserIdOrderByCreatedAtAsc(UUID.fromString(userId)).size());

        mvc.perform(get("/api/folders")
                        .header("Authorization", AuthTestSupport.bearer(token)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.folders", hasSize(1)))
                .andExpect(jsonPath("$.folders[0].name").value("Biology"))
                .andExpect(jsonPath("$.unfiledCount").value(1));
    }
}
