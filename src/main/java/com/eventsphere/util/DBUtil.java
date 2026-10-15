package com.eventsphere.util;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import java.sql.Connection;
import java.sql.SQLException;

// EventSphere project (TYBCA) - database helper class.
// All DAO classes call getConnection() to talk to PostgreSQL.
// A HikariCP pool is used so connections are reused instead of
// opening a new one for every query, which keeps the site fast.
public class DBUtil {
    private static final String DB_URL = setting("EVENTSPHERE_DB_URL", "jdbc:postgresql://localhost:5432/eventsphere");
    private static final String DB_USER = setting("EVENTSPHERE_DB_USER", "postgres");
    private static final String DB_PASSWORD = setting("EVENTSPHERE_DB_PASSWORD", "root");

    private static volatile HikariDataSource DATA_SOURCE;

    private static HikariDataSource dataSource() throws SQLException {
        HikariDataSource ds = DATA_SOURCE;
        if (ds == null || ds.isClosed()) {
            synchronized (DBUtil.class) {
                ds = DATA_SOURCE;
                if (ds == null || ds.isClosed()) {
                    try {
                        HikariConfig config = new HikariConfig();
                        config.setJdbcUrl(DB_URL);
                        config.setUsername(DB_USER);
                        config.setPassword(DB_PASSWORD);
                        config.setDriverClassName("org.postgresql.Driver");
                        config.setMaximumPoolSize(10);
                        config.setMinimumIdle(2);
                        config.setConnectionTimeout(10000);
                        config.setIdleTimeout(300000);
                        config.setMaxLifetime(900000);
                        config.setPoolName("eventsphere-pool");
                        ds = new HikariDataSource(config);
                    } catch (RuntimeException e) {
                        throw new SQLException("Could not initialize database pool", e);
                    }
                    DATA_SOURCE = ds;
                }
            }
        }
        return ds;
    }

    public static Connection getConnection() throws SQLException {
        return dataSource().getConnection();
    }

    private static String setting(String name, String defaultValue) {
        String value = System.getenv(name);
        return value == null || value.isBlank() ? defaultValue : value;
    }

    public static void closeConnection(Connection conn) {
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {

            }
        }
    }
}
