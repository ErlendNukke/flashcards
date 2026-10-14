package com.flashcards.web;

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
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@AutoConfigureMockMvc
class AuthOwnershipIntegrationTest extends IntegrationTestBase {

    @Autowired
    MockMvc mvc;

    @Test
    void userCannotSeeAnotherUsersCards() throws Exception {
        String tokenA = AuthTestSupport.register(mvc, "owner_a_" + UUID.randomUUID().toString().substring(0, 8), "password123", UUID.randomUUID().toString());
        String tokenB = AuthTestSupport.register(mvc, "owner_b_" + UUID.randomUUID().toString().substring(0, 8), "password123", UUID.randomUUID().toString());

        var created = mvc.perform(post("/api/cards")
                        .header("Authorization", AuthTestSupport.bearer(tokenA))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(JSON.writeValueAsString(Map.of(
                                "question", "Secret?",
                                "answer", "Yes"
                        ))))
                .andExpect(status().isCreated())
                .andReturn();

        String cardId = JSON.readTree(created.getResponse().getContentAsString()).get("id").asText();

        mvc.perform(get("/api/cards")
                        .header("Authorization", AuthTestSupport.bearer(tokenB)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(0)));

        mvc.perform(get("/api/cards/" + cardId)
                        .header("Authorization", AuthTestSupport.bearer(tokenB)))
                .andExpect(status().isNotFound());
    }
}
