package com.flashcards.config;

import org.junit.jupiter.api.Test;
import org.springframework.boot.SpringApplication;
import org.yaml.snakeyaml.Yaml;

import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;

class ProdJwtSecretConfigTest {

    @Test
    @SuppressWarnings("unchecked")
    void prodProfileRequiresJwtSecretWithoutDefault() throws Exception {
        Map<String, Object> prod = loadProdDocument();
        assertNotNull(prod, "prod profile document missing in application.yml");

        Map<String, Object> flashcards = (Map<String, Object>) prod.get("flashcards");
        assertNotNull(flashcards);
        Map<String, Object> jwt = (Map<String, Object>) flashcards.get("jwt");
        assertNotNull(jwt);
        assertEquals("${JWT_SECRET}", jwt.get("secret"));
    }

    @Test
    void prodContextFailsWhenJwtSecretMissing() {
        assertThrows(
                Exception.class,
                () -> SpringApplication.run(
                        com.flashcards.FlashcardsApplication.class,
                        "--spring.profiles.active=prod",
                        "--spring.main.web-application-type=none",
                        "--spring.datasource.url=jdbc:h2:mem:prod-jwt-test",
                        "--spring.datasource.driver-class-name=org.h2.Driver",
                        "--spring.jpa.database-platform=org.hibernate.dialect.H2Dialect"
                )
        );
    }

    @SuppressWarnings("unchecked")
    private static Map<String, Object> loadProdDocument() throws Exception {
        try (var reader = new InputStreamReader(
                ProdJwtSecretConfigTest.class.getClassLoader().getResourceAsStream("application.yml"),
                StandardCharsets.UTF_8)) {
            Yaml yaml = new Yaml();
            for (Object doc : yaml.loadAll(reader)) {
                Map<String, Object> root = (Map<String, Object>) doc;
                Map<String, Object> spring = (Map<String, Object>) root.get("spring");
                if (spring == null) {
                    continue;
                }
                Map<String, Object> config = (Map<String, Object>) spring.get("config");
                if (config == null) {
                    continue;
                }
                Map<String, Object> activate = (Map<String, Object>) config.get("activate");
                if (activate != null && "prod".equals(activate.get("on-profile"))) {
                    return root;
                }
            }
        }
        return null;
    }
}
