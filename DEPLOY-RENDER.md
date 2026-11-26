# Deploy EventSphere to Render + Neon (free tier)

## 1. Neon (PostgreSQL)

1. Create a free Neon project and a database named `eventsphere`.
2. In the Neon dashboard, copy the **pooled** connection string, user and password.
3. Load the schema + seed data (use the cloud-safe file — it omits `CREATE DATABASE` and the psql `\c` command):

```powershell
psql "<your Neon connection string>" -f database-neon.sql
```

4. Build the JDBC URL for Render by changing the scheme:

```text
postgresql://user:pass@host/db?sslmode=require
        ->  jdbc:postgresql://user:pass@host/db?sslmode=require
```

## 2. GitHub

Commit and push the project root (it must contain `pom.xml`, `src/`, `database-neon.sql` and `Dockerfile`). The Dockerfile builds the WAR with Maven/JDK 25, then deploys it to Tomcat 11 as `ROOT.war` so the site opens at `/`.

## 3. Render

1. **New → Web Service** → connect the GitHub repo.
2. Runtime: **Docker**, plan: **Free**.
3. Add environment variables:

| Key | Value |
| --- | --- |
| `EVENTSPHERE_DB_URL` | `jdbc:postgresql://...` from step 1 |
| `EVENTSPHERE_DB_USER` | Neon user |
| `EVENTSPHERE_DB_PASSWORD` | Neon password |

4. Click **Deploy**. Render supplies `PORT`, but this image listens on 8080 — set **Health Check Path** to `/` if Render asks, and leave the default web port at 8080 (Render detects `EXPOSE 8080`).
5. Your URL will be `https://<service-name>.onrender.com`.

## 4. Verify

- `https://<service-name>.onrender.com/` returns the homepage.
- Log in as `admin@eventsphere.com` / `Admin@141#233` (seeded in `database-neon.sql`), or `john@example.com` / `password`.
- Complete a venue booking; it should redirect to `?success=Booking+submitted`.

## Caveats

- **Free tier sleeps** after ~15 minutes of inactivity; the first visit after a break takes 30–50 seconds to wake.
- **Change the seeded passwords** before making the URL public (BCrypt hashes are in `database-neon.sql`).
- **Forgot-password emails are not delivered**: `MailUtil` has no SMTP implementation. Reset links are generated and stored, and a fallback in-app notification/server log is used. Implement Jakarta Mail + set `EVENTSPHERE_SMTP_*` env vars if you need real emails.
- Do not run `database.sql` on Neon — it contains `CREATE DATABASE eventsphere;` and `\c eventsphere;`, which only work with local psql. Use `database-neon.sql` instead.
- The app reads DB settings only from the three `EVENTSPHERE_DB_*` environment variables (see `DBUtil.java`), so no code changes are needed for Neon.
