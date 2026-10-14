package com.flashcards.web;

import com.flashcards.support.IntegrationTestBase;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Map;
import java.util.UUID;

import static org.hamcrest.Matchers.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@AutoConfigureMockMvc
class FoldersApiIntegrationTest extends IntegrationTestBase {

    @Autowired
    MockMvc mvc;

    @Test
    void folderCrudAndDeleteMovesCardsToUnfiled() throws Exception {
        String device = UUID.randomUUID().toString();

        var created = mvc.perform(post("/api/folders")
                        .header(CardController.DEVICE_ID_HEADER, device)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(JSON.writeValueAsString(Map.of("name", "Biology"))))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.name").value("Biology"))
                .andExpect(jsonPath("$.cardCount").value(0))
                .andReturn();

        String folderId = JSON.readTree(created.getResponse().getContentAsString()).get("id").asText();

        mvc.perform(post("/api/folders")
                        .header(CardController.DEVICE_ID_HEADER, device)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(JSON.writeValueAsString(Map.of("name", "biology"))))
                .andExpect(status().isConflict());

        mvc.perform(post("/api/cards")
                        .header(CardController.DEVICE_ID_HEADER, device)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(JSON.writeValueAsString(Map.of(
                                "question", "Q1",
                                "answer", "A1",
                                "folderId", folderId
                        ))))
                .andExpect(status().isCreated());

        mvc.perform(get("/api/folders")
                        .header(CardController.DEVICE_ID_HEADER, device))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.unfiledCount").value(0))
                .andExpect(jsonPath("$.folders[0].cardCount").value(1));

        mvc.perform(put("/api/folders/" + folderId)
                        .header(CardController.DEVICE_ID_HEADER, device)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(JSON.writeValueAsString(Map.of("name", "Chemistry"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.name").value("Chemistry"));

        mvc.perform(delete("/api/folders/" + folderId)
                        .header(CardController.DEVICE_ID_HEADER, device))
                .andExpect(status().isNoContent());

        mvc.perform(get("/api/folders")
                        .header(CardController.DEVICE_ID_HEADER, device))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.folders", hasSize(0)))
                .andExpect(jsonPath("$.unfiledCount").value(1));

        mvc.perform(get("/api/cards")
                        .header(CardController.DEVICE_ID_HEADER, device)
                        .param("unfiled", "true"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].folderId").isEmpty());
    }
}
