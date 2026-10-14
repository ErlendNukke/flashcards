package com.flashcards.security;

import com.flashcards.domain.AppUser;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

public final class SecurityUtils {

    private SecurityUtils() {
    }

    public static AppUser requireCurrentUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !(auth.getPrincipal() instanceof AppUser user)) {
            throw new IllegalStateException("Not authenticated");
        }
        return user;
    }
}
