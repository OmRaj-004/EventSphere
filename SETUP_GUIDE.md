# EventSphere - Complete Setup Guide

## Step 1: Prerequisites Installation

### Windows

#### 1.1 Install Java 25+

1. Download from: https://learn.microsoft.com/java/openjdk/download (this machine runs Java 26)
2. Run the installer and follow the prompts
3. Set JAVA_HOME environment variable:
   - Open Environment Variables (Windows + Pause → Advanced System Settings)
   - Click "Environment Variables"
   - Add new System Variable: `JAVA_HOME = C:\Program Files\Java\jdk-26.0.2`
4. Add Java to PATH:
   - Edit System Variable `PATH`
   - Add: `C:\Program Files\Java\jdk-26.0.2\bin`

Verify installation:
```bash
java -version
javac -version
```

#### 1.2 Install Maven 3.8+

1. Download from: https://maven.apache.org/download.cgi
2. Extract to: `C:\Program Files\Apache Software Foundation\Maven 3.9.16`
3. Set MAVEN_HOME environment variable:
   - Add: `MAVEN_HOME = C:\Program Files\Apache Software Foundation\Maven 3.9.16`
4. Add Maven to PATH:
   - Add: `C:\Program Files\Apache Software Foundation\Maven 3.9.16\bin`

Verify installation:
```bash
mvn -version
```

#### 1.3 Install PostgreSQL 12+

1. Download from: https://www.postgresql.org/download/windows/ (this machine runs PostgreSQL 18)
2. Run installer
3. Default settings:
   - Port: 5432
   - Username: postgres
   - Password: your choice (this machine uses `root`)
4. Remember the password for database setup (it must match `EVENTSPHERE_DB_PASSWORD` / `DBUtil.java`)

Verify installation:
```bash
psql --version
```

#### 1.4 Install Apache Tomcat 11

1. Download from: https://tomcat.apache.org/download-11.cgi
2. Extract to: `C:\Program Files\Apache Software Foundation\Tomcat 11.0`
3. Set environment variables:
   - Add: `CATALINA_HOME = C:\Program Files\Apache Software Foundation\Tomcat 11.0`
   - Add: `CATALINA_BASE = C:\Program Files\Apache Software Foundation\Tomcat 11.0`
4. Add Tomcat to PATH:
   - Add: `C:\Program Files\Apache Software Foundation\Tomcat 11.0\bin`

On this machine Tomcat runs as the Windows service `Tomcat11` (Startup: Manual):

```powershell
Start-Service -Name "Tomcat11"
Restart-Service -Name "Tomcat11" -Force
Get-Service -Name "Tomcat11"
```

## Step 2: Database Setup

### 2.1 Create EventSphere Database

Open PowerShell or Command Prompt and connect to PostgreSQL:

```bash
psql -U postgres
```

Enter your PostgreSQL password when prompted.

### 2.2 Execute Database Script

Run the database initialization script:

```bash
# From Windows Command Prompt
psql -U postgres -f "D:\BCA Content\Assignments and Experiments\Sem5\PMM\EventSphere\database.sql"

# From PowerShell
Get-Content "D:\BCA Content\Assignments and Experiments\Sem5\PMM\EventSphere\database.sql" | psql -U postgres
```

### 2.3 Verify Database Creation

```sql
psql -U postgres -d eventsphere
\dt
SELECT * FROM venues;
```

You should see 13 tables and sample data.

## Step 3: Configure Database Connection

### 3.1 Update DBUtil.java (if needed)

Edit: `src/main/java/com/eventsphere/util/DBUtil.java`

Update connection parameters if different from defaults:

```java
private static final String DB_URL = "jdbc:postgresql://localhost:5432/eventsphere";
private static final String DB_USER = "postgres";
private static final String DB_PASSWORD = "root";  // Change this if different
<<<<<<< HEAD
```

No code change is needed if you prefer environment variables (read at startup):

```powershell
$env:EVENTSPHERE_DB_URL = "jdbc:postgresql://localhost:5432/eventsphere"
$env:EVENTSPHERE_DB_USER = "postgres"
$env:EVENTSPHERE_DB_PASSWORD = "root"
=======
>>>>>>> 83a82695c72a46a2fa46013eb6b785b5572bcbbd
```

## Step 4: Build the Project

### 4.1 Navigate to Project Directory

```bash
cd "D:\BCA Content\Assignments and Experiments\Sem5\PMM\EventSphere"
```

### 4.2 Clean and Build

```bash
# Download dependencies and compile
mvn clean compile

# Expected output: BUILD SUCCESS
```

If this fails, check:
- Java is properly installed (`java -version`)
- Maven is properly installed (`mvn -version`)
- Internet connection available for downloading dependencies

### 4.3 Package as WAR

```bash
mvn package

# Expected: target/EventSphere.war created
```

This creates the deployable WAR file.

## Step 5: Deploy to Tomcat

### 5.1 Start Tomcat

```bash
# Windows
catalina.bat start

# PowerShell
& $env:CATALINA_HOME\bin\catalina.bat start
```

Wait for Tomcat to start (check console for "Server startup in X ms").

### 5.2 Deploy Application

**Option A: Copy WAR File**
```bash
copy target\EventSphere.war "%CATALINA_HOME%\webapps\"
```

**Option B: Windows service redeploy (this machine)**
```powershell
Copy-Item ".\target\EventSphere.war" "C:\Program Files\Apache Software Foundation\Tomcat 11.0\webapps\EventSphere.war" -Force
Restart-Service -Name "Tomcat11" -Force
```

### 5.3 Verify Deployment

Open browser and navigate to:
```
http://localhost:8080/EventSphere
```

You should see the EventSphere homepage.

## Step 6: First Time Access

### 6.1 Admin Login

Navigate to: `http://localhost:8080/EventSphere/login`

**Credentials:**
- Email: `admin@eventsphere.com`
- Password: `Admin@141#233`

### 6.2 Create Customer Account

1. Click "Register" on login page
2. Fill in:
   - Full Name: Your Name
   - Email: your-email@example.com
   - Password: (6+ characters)
   - Confirm Password: (same as above)
3. Click "Create Account"
4. Login with your new credentials

## Troubleshooting

### Issue: Maven Build Fails with "mvn not found"

**Solution:**
```bash
# Verify Maven installation
mvn -version

# If not found, add to PATH (this machine):
set PATH=%PATH%;C:\Program Files\Apache Software Foundation\Maven 3.9.16\bin

# Try again
mvn clean package
```

### Issue: Database Connection Error

**Error Message:** "Failed to connect to database"

**Solutions:**
1. Check PostgreSQL is running:
   ```powershell
   Get-Service -Name "postgresql-x64-18"
   Start-Service -Name "postgresql-x64-18"
   ```

2. Verify credentials in DBUtil.java:
   ```bash
   # Test connection
   psql -U postgres -d eventsphere
   ```

3. Check firewall isn't blocking port 5432

### Issue: Tomcat Won't Start

**Error Message:** "Address already in use"

**Solutions:**
1. Tomcat already running - kill existing process:
   ```bash
   taskkill /F /IM java.exe
   ```

2. Another application using port 8080:
   ```bash
   # Find process on port 8080
   netstat -ano | findstr :8080
   
   # Kill process (replace PID with actual number)
   taskkill /F /PID <PID>
   ```

### Issue: Application Not Accessible at localhost:8080/EventSphere

**Solutions:**
1. Check Tomcat logs (`C:\Program Files\Apache Software Foundation\Tomcat 11.0\logs\`
   — `catalina.YYYY-MM-DD.log` for deploys, `tomcat11-stdout` log for app/pool output):

2. Check if WAR deployed successfully:
   ```bash
   dir "%CATALINA_HOME%\webapps"
   ```

3. Restart Tomcat:
   ```bash
   catalina.bat stop
   timeout /t 5
   catalina.bat start
   ```

### Issue: Login Always Shows "Invalid email or password"

**Solutions:**
1. Check the matching role table in the single EventSphere database:
   ```sql
   SELECT id, email FROM admin_users;
   SELECT id, email FROM customer_users;
   ```

2. Confirm the `password_hash` column exists in both role tables and that the application is reading the `role` form field correctly:
   ```sql
   SELECT id, email, password_hash FROM admin_users;
   SELECT id, email, password_hash FROM customer_users;
   ```

3. Re-deploy application:
   ```powershell
   Copy-Item ".\target\EventSphere.war" "C:\Program Files\Apache Software Foundation\Tomcat 11.0\webapps\EventSphere.war" -Force
   Restart-Service -Name "Tomcat11" -Force
   ```

### Issue: All database pages show HTTP 500 (`No suitable driver`)

**Cause:** HikariCP cannot see the PostgreSQL driver (`DBUtil` static init fails with
`java.sql.SQLException: No suitable driver` in Tomcat's `stdout` log).

**Solutions:**
1. Confirm `postgresql-42.7.3.jar` is inside `webapps\EventSphere\WEB-INF\lib\` (rebuild with `mvn package` if unsure).
2. Restart the `Tomcat11` service after every WAR redeploy so the pool re-initialises cleanly.
3. If it persists, register the driver explicitly in `DBUtil.initializeDataSource()` before building the pool:
   ```java
   Class.forName("org.postgresql.Driver");
   config.setDriverClassName("org.postgresql.Driver");
   ```

## Development Workflow

### Making Changes

1. Edit source files in `src/` directory
2. Rebuild:
   ```bash
   mvn clean package
   ```
3. Redeploy:
   ```powershell
   Copy-Item ".\target\EventSphere.war" "C:\Program Files\Apache Software Foundation\Tomcat 11.0\webapps\EventSphere.war" -Force
   Restart-Service -Name "Tomcat11" -Force
   ```
4. Refresh browser

### Debugging

Enable Tomcat debug output:

1. Edit `%CATALINA_HOME%\bin\catalina.bat`
2. Add before `"%EXECUTABLE%" %ACTION%`:
   ```batch
   set JPDA_SUSPEND=n
   set JPDA_TRANSPORT=dt_socket
   set JPDA_ADDRESS=5005
   set JPDA_OPTS=-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005
   ```
3. Start with debug flag:
   ```bash
   catalina.bat jpda start
   ```

## Performance Optimization

### Tomcat Configuration

Edit `%CATALINA_HOME%\conf\server.xml`:

```xml
<Connector port="8080" protocol="HTTP/1.1"
    maxThreads="200"
    minSpareThreads="10"
    maxSpareThreads="50"
    acceptCount="100"
    connectionTimeout="20000" />
```

### Database Connection Pooling

To add connection pooling, modify DBUtil.java or update pom.xml with HikariCP:

```xml
<dependency>
    <groupId>com.zaxxer</groupId>
    <artifactId>HikariCP</artifactId>
    <version>5.0.1</version>
</dependency>
```

## Security Checklist

- [ ] Changed admin password
- [ ] PostgreSQL password changed from default
- [ ] Tomcat running on HTTPS in production
- [ ] Database backups configured
- [ ] Firewall rules for ports 8080, 5432 configured
- [ ] Input validation verified
- [ ] SQL injection testing completed
- [ ] Session timeout configured

## Backup and Recovery

### Database Backup

```bash
# Backup database
pg_dump -U postgres eventsphere > eventsphere_backup.sql

# Restore from backup
psql -U postgres -d eventsphere < eventsphere_backup.sql
```

### Application Backup

```bash
# Backup application files
xcopy "D:\BCA Content\Assignments and Experiments\Sem5\PMM\EventSphere" backup_folder /E /I
```

## Monitoring

### Tomcat Logs

View real-time logs:
```bash
type "%CATALINA_HOME%\logs\catalina.out"

# Or use tail (if available)
tail -f "%CATALINA_HOME%\logs\catalina.out"
```

### Database Logs

```bash
# PostgreSQL logs location
# Typically: C:\Program Files\PostgreSQL\18\data\log\
```

## Stopping the Application

```powershell
# Stop Tomcat (Windows service on this machine)
Stop-Service -Name "Tomcat11"

# Start it again when needed
Start-Service -Name "Tomcat11"
```

## Next Steps

1. Configure email for notifications
2. Set up HTTPS/SSL certificates
3. Implement payment gateway integration
4. Set up automated database backups
5. Configure monitoring and alerting
6. Deploy to production server

---

For additional help, refer to README.md or project documentation.
