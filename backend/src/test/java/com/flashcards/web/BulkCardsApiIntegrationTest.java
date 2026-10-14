package com.flashcards.web;

import com.flashcards.support.AuthTestSupport;
import com.flashcards.support.IntegrationTestBase;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import java.util.List;
import java.util.Map;
import java.util.UUID;

import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@AutoConfigureMockMvc
class BulkCardsApiIntegrationTest extends IntegrationTestBase {

    @Autowired
    MockMvc mvc;

    @Test
    void bulkMoveAndBulkDelete() throws Exception {
        String device = UUID.randomUUID().toString();
        String token = AuthTestSupport.register(mvc, "bulk_" + UUID.randomUUID().toString().substring(0, 8), "password123", device);

        MvcResult folder = mvc.perform(post("/api/folders")
                        .header("Authorization", AuthTestSupport.bearer(token))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(JSON.writeValueAsString(Map.of("name", "Deck A"))))
                .andExpect(status().isCreated())
                .andReturn();
        String folderId = JSON.readTree(folder.getResponse().getContentAsString()).get("id").asText();

        String id1 = createCard(token, "One", "1");
        String id2 = createCard(token, "Two", "2");

        mvc.perform(post("/api/cards/bulk-move")
                        .header("Authorization", AuthTestSupport.bearer(token))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(JSON.writeValueAsString(Map.of(
                                "ids", List.of(id1, id2),
                                "folderId", folderId
                        ))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.affected").value(2));

        mvc.perform(get("/api/cards")
                        .header("Authorization", AuthTestSupport.bearer(token))
                        .param("folderId", folderId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(2)));

        mvc.perform(post("/api/cards/bulk-delete")
                        .header("Authorization", AuthTestSupport.bearer(token))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(JSON.writeValueAsString(Map.of("ids", List.of(id1)))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.affected").value(1));

        mvc.perform(get("/api/cards")
                        .header("Authorization", AuthTestSupport.bearer(token))
                        .param("folderId", folderId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)));
    }

    private String createCard(String token, String q, String a) throws Exception {
        MvcResult result = mvc.perform(post("/api/cards")
                        .header("Authorization", AuthTestSupport.bearer(token))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(JSON.writeValueAsString(Map.of("question", q, "answer", a))))
                .andExpect(status().isCreated())
                .andReturn();
        return JSON.readTree(result.getResponse().getContentAsString()).get("id").asText();
    }
}
