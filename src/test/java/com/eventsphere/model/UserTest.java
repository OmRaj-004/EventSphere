package com.eventsphere.model;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.time.LocalDateTime;
import org.junit.jupiter.api.Test;

class UserTest {

    @Test
    void shouldCreateUserWithConstructorAndExposeValues() {
        User user = new User(7, "Alice Johnson", "alice@example.com", "ADMIN");

        assertEquals(7, user.getId());
        assertEquals("Alice Johnson", user.getFullName());
        assertEquals("alice@example.com", user.getEmail());
        assertEquals("ADMIN", user.getRole());
        assertTrue(user.isAdmin());
        assertFalse(user.isCustomer());
    }

    @Test
    void shouldSetAndGetFieldValues() {
        User user = new User();
        LocalDateTime now = LocalDateTime.of(2026, 9, 1, 10, 15, 0);

        user.setId(12);
        user.setFullName("Bob Smith");
        user.setEmail("bob@example.com");
        user.setPasswordHash("hashed-password");
        user.setRole("CUSTOMER");
        user.setCreatedAt(now);
        user.setUpdatedAt(now.plusHours(1));

        assertEquals(12, user.getId());
        assertEquals("Bob Smith", user.getFullName());
        assertEquals("bob@example.com", user.getEmail());
        assertEquals("hashed-password", user.getPasswordHash());
        assertEquals("CUSTOMER", user.getRole());
        assertEquals(now, user.getCreatedAt());
        assertEquals(now.plusHours(1), user.getUpdatedAt());
        assertFalse(user.isAdmin());
        assertTrue(user.isCustomer());
    }

    @Test
    void shouldProduceReadableToString() {
        User user = new User();
        user.setId(3);
        user.setFullName("Carol");
        user.setEmail("carol@example.com");
        user.setRole("ADMIN");

        String value = user.toString();

        assertTrue(value.contains("User{"));
        assertTrue(value.contains("id=3"));
        assertTrue(value.contains("Carol"));
        assertTrue(value.contains("ADMIN"));
    }
}
