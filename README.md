# EventSphere - Event & Venue Booking Platform

## Project Overview

EventSphere is a web application for booking and managing event venues. It uses Java 21, Jakarta Servlet 6.1, JSP 4.0, PostgreSQL, and Apache Tomcat 11.

## Technology Stack

- **Java**: 21 (language level; verified running on Java 26)
- **Web Framework**: Jakarta Servlet 6.1 (Tomcat 11 compatible)
- **View Layer**: JSP 4.0
- **Frontend**: HTML5, CSS3, Vanilla JavaScript
- **Database**: PostgreSQL (developed against PostgreSQL 18)
- **Build Tool**: Maven 3.8+
- **Test Framework**: JUnit 5
- **Password Hashing**: BCrypt (cost 12)
- **Connection Pool**: HikariCP
- **Email**: Jakarta Mail (SMTP optional; disabled by default, falls back to logs + in-app notices)
- **Migrations**: Flyway (available; schema is also provided as `database.sql`)
- **Authentication Model**: Separate `admin_users`, `customer_users` and `host_users` tables with BCrypt `password_hash` fields

## Project Structure

```
EventSphere/
├── pom.xml                           # Maven configuration (v1.0.3, Java 21, WAR: EventSphere.war)
├── database.sql                      # Database schema (13 tables) and sample data
├── README.md                         # This file
├── SETUP_GUIDE.md                    # Setup instructions
├── PROJECT_SUMMARY.md                # Implementation summary
├── FILE_MANIFEST.md                  # File manifest
├── src/
│   └── main/
│       ├── java/com/eventsphere/      # 53 classes
│       │   ├── model/               # Entities: User, Venue, Event, Booking, Bill,
│       │   │                        #   Feedback, Notification, PromoCode, AuditLog
│       │   ├── dao/                 # DAOs: User, Venue, Event, Booking, Bill, Feedback,
│       │   │                        #   Notification, Promo, PasswordReset, LoginToken, Audit, ...
│       │   ├── servlet/             # Login, Logout, Register, Venue, Contact, Feedback,
│       │   │                        #   Forgot/ResetPassword, Notification, ...
│       │   ├── controller/          # Booking, Admin (booking/venue/customer/host/promo/
│       │   │                        #   feedback), Billing, PDF bills, Host venues
│       │   ├── filter/              # Authentication, Admin, Customer, Host,
│       │   │                        #   RememberMe, RateLimit
│       │   └── util/                # DBUtil (HikariCP), MailUtil, TokenUtil,
│       │                            #   EscapeUtil, FormatUtil
│       └── webapp/                   # 30 JSP pages
│           ├── index.jsp            # Home page (hero search, popular venues, about, contact)
│           ├── register.jsp         # Registration page
│           ├── login.jsp            # Admin / customer / host login
│           ├── venues.jsp           # Venue listing (AJAX filters, pagination, multi-select)
│           ├── venue-details.jsp    # Details + availability calendar + reviews + lightbox
│           ├── booking.jsp          # Booking form (live price estimate, inline validation)
│           ├── booking-multi.jsp    # Multi-venue booking
│           ├── forgot-password.jsp / reset-password.jsp
│           ├── WEB-INF/
│           │   └── web.xml          # Deployment descriptor
│           ├── css/
│           │   └── style.css        # Global styles (~75 KB: theme, dashboards, toasts,
│           │                        #   confirm modal, lightbox, skeletons)
│           ├── js/
│           │   └── script.js        # Client-side logic (~21 KB: validation, AJAX search,
│           │                        #   confirm modal, toasts, lightbox, price estimate)
│           ├── images/              # Venue photos + vector brand logo
│           │   ├── eventsphere-logo.svg   # Navbar logo (vector recreation of the emblem)
│           │   ├── eventsphere-icon.svg   # Favicon (emblem mark)
│           │   └── EventSphere Logo.png   # Original artwork (kept for print invoice)
│           ├── customer/            # Dashboard, bookings, booking-edit, bill,
│           │                        #   feedback, notifications
│           ├── admin/               # Dashboard, bookings, venues, venue-form, customers,
│           │                        #   hosts, promos, admins, analytics, notifications
│           ├── host/                # Host dashboard and venue management
│           └── error/
│               ├── 404.jsp          # 404 error page
│               └── 500.jsp          # 500 error page
```

## Prerequisites

- **Java 21** or later (developed with Java 26)
- **Maven 3.8+**
- **PostgreSQL 12+** (developed against PostgreSQL 18)
- **Apache Tomcat 11**
- **Git** (optional)

## Authentication Flow

The login page presents separate role-aware forms for administrators and normal customers. The admin form posts the role field `ADMIN`, and the customer form posts `CUSTOMER`. The servlet and DAO route the request through role-specific database tables so admin and customer identity records stay out of a single shared login table.

The database model has been separated into dedicated credential tables:

- `admin_users` for administrators
- `customer_users` for normal users
- `host_users` for venue hosts (created by an admin)

Passwords are stored as BCrypt hashes (cost 12) in `password_hash`. Login verifies the submitted password with BCrypt.

## Installation & Setup

### 1. Database Setup

```bash
# Create PostgreSQL database and tables
psql -U postgres -f database.sql
```

**Database Configuration (local defaults):**
- Database Name: `eventsphere`
- User: `postgres`
- Password: `root`
- Host: `localhost`
- Port: `5432`

These can be overridden without code changes via environment variables
(`DBUtil.java` reads them at startup):

```
EVENTSPHERE_DB_URL=jdbc:postgresql://localhost:5432/eventsphere
EVENTSPHERE_DB_USER=postgres
EVENTSPHERE_DB_PASSWORD=root
```

Update `DBUtil.java` if your PostgreSQL configuration is different:

```java
private static final String DB_URL = "jdbc:postgresql://your-host:5432/eventsphere";
private static final String DB_USER = "your-username";
private static final String DB_PASSWORD = "your-password";
```

### 2. Build the Project

```bash
# Clean and build WAR package
mvn clean package

# Build output: target/EventSphere.war
```

### 3. Deploy to Tomcat

**Option A: Copy WAR to Tomcat**
```bash
cp target/EventSphere.war $CATALINA_HOME/webapps/
```

Tomcat 11 deployment uses the generated WAR copied into the Tomcat `webapps` directory.

### 4. Run the Application

Start Tomcat and access the application at:
```
http://localhost:8080/EventSphere
```

## Database Schema

### Tables

1. **admin_users** - Stores administrators
   - Fields: id, full_name, email, password_hash, created_at, updated_at

2. **customer_users** - Stores normal customers
   - Fields: id, full_name, email, password_hash, created_at, updated_at

3. **venues** - Available event venues
   - Fields: id, name, description, location, max_capacity, hourly_rate, amenities, image_url, created_by, created_at, updated_at

3. **events** - Customer events
   - Fields: id, name, description, event_type, event_date, start_time, end_time, expected_guests, organizer_id, venue_id, status, created_at, updated_at

4. **bookings** - Venue bookings for events
   - Fields: id, booking_number, event_id, venue_id, customer_id, booking_date, total_amount, advance_paid, status, payment_method, transaction_id, notes, created_at, updated_at

5. **feedback** - Customer reviews and ratings
   - Fields: id, booking_id, customer_id, venue_id, rating, comment, created_at

## User Roles

### Admin Account
- **Email**: admin@eventsphere.com
- **Password**: Admin@141#233
- **Features**: Manage venues, approve bookings, view reports

### Developer Convention: Flash Messages
- Every servlet flash key (`request.getSession().setAttribute("...Success/Error")`)
- must have a renderer on its landing JSP, or failures go invisible.
- Current keys and renderers: `adminBookingSuccess/Error` (admin dashboard),
- `adminFeedbackSuccess/Error` (admin dashboard), `adminPromoSuccess/Error`
- (promos page), `adminHostSuccess/Error` (hosts page), `bookingSuccess/Error`
- (customer dashboard), `feedbackDeleteSuccess/Error` (my reviews page).

### Email (SMTP) Configuration
- Outgoing mail is **disabled by default**: password resets and contact
- messages fall back to server logs + in-app notifications.
- To enable real delivery, set these environment variables and add a
- Jakarta Mail implementation:
- `EVENTSPHERE_SMTP_HOST`, `EVENTSPHERE_SMTP_PORT` (default 587),
- `EVENTSPHERE_SMTP_USER`, `EVENTSPHERE_SMTP_PASSWORD`,
- `EVENTSPHERE_SMTP_FROM`, `EVENTSPHERE_SMTP_TLS` (default true).
- See `com.eventsphere.util.MailUtil` for the integration point.

### Customer Account
- Create via registration form
- Browse and search venues (paginated, rated, with availability calendar)
- Create bookings (single or multi-venue) with promo codes
- Modify pending bookings, view bills (HTML + PDF), manage reviews
- In-app notifications, "remember me" login, self-service password reset

### Host Account
- Created by an admin (admin/hosts.jsp); login with role HOST
- List and manage own venues (photo upload included)
- View bookings for own venues; approvals stay with admins

### Admin Account
- All venue/booking/customer/host/promo management plus analytics,
- audit log, feedback replies, notifications and bill overviews

## API Endpoints

### Authentication
- `GET /` - Home page
- `GET /login` - Login form
- `POST /login` - Process login
- `GET /register` - Registration form
- `POST /register` - Process registration
- `GET /logout` - Logout

### Venues
- `GET /venues` - Browse venues with optional filters
- `GET /venues?action=details&id={id}` - View venue details

### Dashboards
- `GET /customer/dashboard.jsp` - Customer dashboard
- `GET /admin/dashboard.jsp` - Admin dashboard

## Security Features

✅ **Password Storage**
- BCrypt hashes are stored separately in the role-aware `admin_users` and `customer_users` tables
- Login verifies the submitted password with BCrypt

✅ **Session Management**
- HttpSession-based authentication
- 30-minute timeout
- Secure cookies (HttpOnly flag)

✅ **Authorization**
- Role-based access control (Admin/Customer)
- Server-side authorization checks
- User ID verified from session (not user input)

✅ **Database Security**
- Prepared statements for all queries
- Try-with-resources for resource management
- No SQL injection vulnerabilities

✅ **Input Validation**
- HTML5 validation
- JavaScript client-side validation
- Server-side validation required

## Frontend Features

### CSS Framework
- Custom responsive CSS (mobile-friendly, ~75 KB)
- CSS Grid and Flexbox layouts
- Color-coded components (primary, secondary, success, danger)
- Status pills, dashboard panels, stat cards, availability calendar styles
- Toast notifications, in-page confirm modal, image lightbox, skeleton loaders
- `:focus-visible` rings and `prefers-reduced-motion` support

### JavaScript
- Form validation (submit-time + inline per-field errors with `aria-invalid`)
- Live booking price estimate (hourly rate × duration, INR formatting)
- AJAX venue search with skeleton placeholders and `history.pushState` (graceful fallback to full navigation)
- Styled in-page confirm modal replacing all native `confirm()` dialogs; toast fallback replacing `alert()`
- Venue image lightbox (click to enlarge, Esc/overlay-click to close)
- Date picker setup (min = today), currency/date formatting, navbar scroll effect, button loading states

### Branding
- Vector brand logo (`images/eventsphere-logo.svg`, redrawn from the original banquet emblem) used in all navbars
- Emblem-only SVG favicon (`images/eventsphere-icon.svg`); original PNG kept for the print invoice

### Pages

1. **Home Page** (`index.jsp`)
   - Navigation with responsive menu
   - Hero section with call-to-action
   - Venue search filters
   - Popular venues showcase
   - About and contact sections

2. **Registration** (`register.jsp`)
   - Full name, email, password validation
   - Client-side and server-side validation
   - Password confirmation
   - Link to login

3. **Login** (`login.jsp`)
   - Email and password authentication
   - Error message display
   - Links to registration and forgot password

4. **Browse Venues** (`venues.jsp`)
   - List all available venues
   - Search and filter options
   - Venue cards with details
   - Call-to-action buttons

5. **Customer Dashboard** (`customer/dashboard.jsp`)
   - Profile information
   - My bookings list
   - Quick actions
   - Statistics

6. **Admin Dashboard** (`admin/dashboard.jsp`)
   - System statistics
   - Venue management
   - Booking management
   - Activity logs

## DAO Pattern Implementation

The application uses the Data Access Object (DAO) pattern:

- **UserDAO** - User registration, authentication, profile updates
- **VenueDAO** - Venue CRUD operations, search functionality
- **EventDAO** - Event management (create, update, delete)
- **BookingDAO** - Booking creation, status management, queries
- **FeedbackDAO** - Customer feedback and ratings

## Error Handling

- **404 Error Page** - Handles missing resources
- **500 Error Page** - Handles server errors
- **Input Validation** - Prevents invalid data submission
- **Database Errors** - Logged without exposing to users

## Testing

### Manual Testing Checklist

- [ ] User Registration
  - [ ] Create new account
  - [ ] Email validation
  - [ ] Password requirements
  - [ ] Duplicate email prevention

- [ ] User Login
  - [ ] Correct credentials
  - [ ] Incorrect password
  - [ ] Invalid email
  - [ ] Session creation

- [ ] Venue Operations
  - [ ] List venues
  - [ ] Search by capacity
  - [ ] Filter by price
  - [ ] View details

- [ ] Security
  - [ ] SQL injection attempts blocked
  - [ ] Session hijacking prevention
  - [ ] Password hashing verified
  - [ ] Authorization enforced

## Deployment Checklist

- [ ] PostgreSQL database created and running
- [ ] All tables created with correct schema
- [ ] DBUtil.java configured with correct credentials
- [ ] Java 21+ installed
- [ ] Maven build successful (`mvn clean package`)
- [ ] WAR file generated without errors
- [ ] Tomcat 11 installed and configured
- [ ] Tomcat environment variables set
- [ ] WAR deployed to Tomcat
- [ ] Application accessible at http://localhost:8080/EventSphere
- [ ] Admin account working
- [ ] Customer registration working
- [ ] Venues displaying correctly

## Configuration Files

### pom.xml
Maven configuration with dependencies:
- Jakarta Servlet 6.1.0
- Jakarta JSP 4.0.0
- PostgreSQL JDBC 42.7.3
- BCrypt 0.10.2, HikariCP, Logback, JSTL
- Jakarta JSON and JSON-B APIs, Jakarta Mail
- JUnit 5 + Mockito + Testcontainers (test scope)

### web.xml
Deployment descriptor with:
- Welcome file configuration
- Session configuration
- Error page mapping
- Servlet mappings (via annotations)

### database.sql
SQL script with:
- Database and table creation
- Indexes for performance
- Sample data for testing

## Troubleshooting

### Maven Build Issues
```bash
# Clear Maven cache
mvn clean install -U

# Check dependencies
mvn dependency:tree
```

### Database Connection Issues
1. Verify PostgreSQL is running
2. Check database credentials in DBUtil.java
3. Verify network connectivity (localhost:5432)
4. Check PostgreSQL logs

### Application Not Displaying
1. Check Tomcat logs: `$CATALINA_HOME/logs/catalina.out`
2. Verify WAR deployment in `$CATALINA_HOME/webapps/`
3. Clear Tomcat work directory: `rm -rf $CATALINA_HOME/work/`
4. Restart Tomcat

## Development Notes

- All SQL queries use PreparedStatement
- No MySQL-specific syntax used (PostgreSQL compatible)
- No framework dependencies (pure Jakarta Servlet)
- Annotation-based servlet mapping
- Try-with-resources for all JDBC operations

## Future Enhancements

- Payment gateway integration
- Multi-language support
- Mobile app API
- Redis caching for large datasets

## License

This project is for educational purposes.

## Support

For issues or questions, please refer to the project documentation or contact the development team.

---

**Last Updated**: October 14, 2026
**Version**: 1.0.3
