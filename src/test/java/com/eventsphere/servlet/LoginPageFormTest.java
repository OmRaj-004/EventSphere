package com.eventsphere.servlet;

import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;

import static org.junit.jupiter.api.Assertions.assertTrue;

public class LoginPageFormTest {

    @Test
    void loginPageShouldContainSeparateAdminAndCustomerLoginForms() throws IOException {
        String loginPage = Files.readString(Paths.get("src", "main", "webapp", "login.jsp"));

        assertTrue(loginPage.contains("Admin Login"), "The login page should expose a dedicated admin login form.");
        assertTrue(loginPage.contains("Customer Login"), "The login page should expose a dedicated customer login form.");
    }

    @Test
    void databaseScriptShouldSeparateAdminAndCustomerTablesAndStorePasswordHashes() throws IOException {
        String databaseScript = Files.readString(Paths.get("database.sql"));

        assertTrue(databaseScript.contains("CREATE TABLE admin_users"), "The database script should declare a dedicated admin user table.");
        assertTrue(databaseScript.contains("CREATE TABLE customer_users"), "The database script should declare a dedicated normal customer user table.");
        assertTrue(databaseScript.contains("password_hash VARCHAR(255) NOT NULL"), "The database script should store BCrypt password hashes.");
    }
}
