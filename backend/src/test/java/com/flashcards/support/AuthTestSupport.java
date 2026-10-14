package com.flashcards.support;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.flashcards.web.CardController;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Map;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

public final class AuthTestSupport {

    private static final ObjectMapper JSON = new ObjectMapper().findAndRegisterModules();

    private AuthTestSupport() {
    }

    public static String register(
            MockMvc mvc,
            String username,
            String password,
            String deviceId
    ) throws Exception {
        var result = mvc.perform(post("/api/auth/register")
                        .header(CardController.DEVICE_ID_HEADER, deviceId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(JSON.writeValueAsString(Map.of(
                                "username", username,
                                "password", password
                        ))))
                .andExpect(status().isCreated())
                .andReturn();
        return extractToken(result.getResponse().getContentAsString());
    }

    public static String login(
            MockMvc mvc,
            String username,
            String password,
            String deviceId
    ) throws Exception {
        var result = mvc.perform(post("/api/auth/login")
                        .header(CardController.DEVICE_ID_HEADER, deviceId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(JSON.writeValueAsString(Map.of(
                                "username", username,
                                "password", password
                        ))))
                .andExpect(status().isOk())
                .andReturn();
        return extractToken(result.getResponse().getContentAsString());
    }

    public static String bearer(String token) {
        return "Bearer " + token;
    }

    private static String extractToken(String body) throws Exception {
        JsonNode node = JSON.readTree(body);
        return node.get("token").asText();
    }
}
