package com.flashcards.web;

import com.flashcards.support.IntegrationTestBase;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Map;
import java.util.UUID;

import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@AutoConfigureMockMvc
class CardsApiIntegrationTest extends IntegrationTestBase {

    @Autowired
    MockMvc mvc;

    @Test
    void crudScopedByDeviceId() throws Exception {
        String deviceA = UUID.randomUUID().toString();
        String deviceB = UUID.randomUUID().toString();

        var createBody = JSON.writeValueAsString(Map.of(
                "question", "What is 2+2?",
                "answer", "4"
        ));

        var created = mvc.perform(post("/api/cards")
                        .header(CardController.DEVICE_ID_HEADER, deviceA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(createBody))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.question").value("What is 2+2?"))
                .andExpect(jsonPath("$.answer").value("4"))
                .andReturn();

        String id = JSON.readTree(created.getResponse().getContentAsString()).get("id").asText();

        mvc.perform(get("/api/cards")
                        .header(CardController.DEVICE_ID_HEADER, deviceA))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)));

        mvc.perform(get("/api/cards")
                        .header(CardController.DEVICE_ID_HEADER, deviceB))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(0)));

        mvc.perform(get("/api/cards/" + id)
                        .header(CardController.DEVICE_ID_HEADER, deviceB))
                .andExpect(status().isNotFound());

        var updateBody = JSON.writeValueAsString(Map.of(
                "question", "Capital of France?",
                "answer", "Paris"
        ));

        mvc.perform(put("/api/cards/" + id)
                        .header(CardController.DEVICE_ID_HEADER, deviceA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(updateBody))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.answer").value("Paris"));

        mvc.perform(delete("/api/cards/" + id)
                        .header(CardController.DEVICE_ID_HEADER, deviceA))
                .andExpect(status().isNoContent());

        mvc.perform(get("/api/cards")
                        .header(CardController.DEVICE_ID_HEADER, deviceA))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(0)));
    }

    @Test
    void missingDeviceIdRejected() throws Exception {
        mvc.perform(get("/api/cards"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("Missing X-Device-Id header"));
    }
}
