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

import static org.hamcrest.Matchers.notNullValue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@AutoConfigureMockMvc
class AuthApiIntegrationTest extends IntegrationTestBase {

    @Autowired
    MockMvc mvc;

    @Test
    void registerLoginAndMe() throws Exception {
        String device = UUID.randomUUID().toString();
        String username = "user_" + UUID.randomUUID().toString().substring(0, 8);

        mvc.perform(post("/api/auth/register")
                        .header(CardController.DEVICE_ID_HEADER, device)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(JSON.writeValueAsString(Map.of(
                                "username", username,
                                "password", "password123"
                        ))))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.token", notNullValue()))
                .andExpect(jsonPath("$.user.username").value(username.toLowerCase()));

        String token = AuthTestSupport.login(mvc, username, "password123", device);

        mvc.perform(get("/api/auth/me")
                        .header("Authorization", AuthTestSupport.bearer(token)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.username").value(username.toLowerCase()));
    }

    @Test
    void usernameIsCaseInsensitive() throws Exception {
        String device = UUID.randomUUID().toString();
        String base = "CaseUser_" + UUID.randomUUID().toString().substring(0, 6);

        AuthTestSupport.register(mvc, base, "password123", device);

        mvc.perform(post("/api/auth/register")
                        .header(CardController.DEVICE_ID_HEADER, device)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(JSON.writeValueAsString(Map.of(
                                "username", base.toUpperCase(),
                                "password", "otherpass99"
                        ))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("Username already taken"));
    }

    @Test
    void loginRejectsWrongPassword() throws Exception {
        String device = UUID.randomUUID().toString();
        String username = "login_" + UUID.randomUUID().toString().substring(0, 8);
        AuthTestSupport.register(mvc, username, "password123", device);

        mvc.perform(post("/api/auth/login")
                        .header(CardController.DEVICE_ID_HEADER, device)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(JSON.writeValueAsString(Map.of(
                                "username", username,
                                "password", "wrong-password"
                        ))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("Invalid username or password"));
    }
}
