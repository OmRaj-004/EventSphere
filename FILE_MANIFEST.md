# EventSphere - Complete File Manifest

**Generated**: October 14, 2026
**Project**: EventSphere Version 1.0.3
**Total Files**: 53 Java classes + 30 JSP pages, with generated build output omitted from version control.

---

## 📁 Project Root Files

### Configuration & Build

| File | Size | Purpose |
|------|------|---------|
| `pom.xml` | 3.6 KB | Maven build configuration |
| `database.sql` | 6.4 KB | PostgreSQL schema and sample data |

### Documentation

| File | Size | Purpose |
|------|------|---------|
| `README.md` | 10.9 KB | Project overview and architecture |
| `SETUP_GUIDE.md` | 9.4 KB | Step-by-step setup and deployment instructions |
| `PROJECT_SUMMARY.md` | 11.9 KB | Implementation checklist and summary |

---

## 📁 Source Code Structure

### Auth Data Model

```
admin_users/                     # Admin login table (BCrypt password_hash)
customer_users/                  # Normal customer login table (BCrypt password_hash)
host_users/                      # Venue host login table (BCrypt password_hash)
```

The database script uses dedicated tables for each account class; passwords are
stored as BCrypt hashes (cost 12) in a `password_hash` column, verified with
`LoginServlet`.

### Java Classes (53 files in 6 packages)

#### Utility Classes (`com.eventsphere.util`)

```
├── DBUtil.java — HikariCP pool (getConnection/closeConnection/shutdown),
│   reads EVENTSPHERE_DB_URL/USER/PASSWORD env vars with localhost defaults
├── MailUtil.java — SMTP integration point (disabled by default)
├── TokenUtil.java — secure random tokens (password reset, remember-me)
├── EscapeUtil.java — HTML output escaping (XSS prevention)
└── FormatUtil.java — date/amount formatting helpers
```

#### Model/Entity Classes (`com.eventsphere.model`: User, Venue, Event, Booking, Bill, Feedback, Notification, PromoCode, AuditLog)
#### Data Access Objects (`com/eventsphere/dao`: User, Venue, Event, Booking, Bill, Feedback, Notification, Promo, PasswordReset, LoginToken, Audit, ...)
#### Servlet Controllers (`com.eventsphere.servlet`: Login, Logout, Register, Venue, Contact, Feedback, FeedbackDelete, Forgot/ResetPassword, Notification)
#### Business Controllers (`com.eventsphere.controller`: Booking, BookingEdit, Bill, PdfBill, AdminBooking, AdminVenue, AdminCustomer, AdminHost, AdminPromo, AdminFeedback, AdminAdmin, HostVenue)
#### Filters (`com.eventsphere.filter`: Authentication, Admin, Customer, Host, RememberMe, RateLimit)

Representative responsibilities (full per-class detail lives in the source):
- `UserDAO`: register/authenticate by role table, BCrypt verify, profile + password updates
- `VenueDAO`: CRUD, filtered search, pagination, host/admin listings
- `BookingDAO`: transactional booking+event creation, status flow, availability checks
- `FeedbackDAO`: ratings, averages, eligibility checks
- `LoginServlet`/`RegisterServlet`: role-aware forms, BCrypt, session fixation protection
- `BookingServlet`/`CustomerBookingServlet`/`BookingEditServlet`: single + multi-venue booking, edits
- `Admin*Servlet`: bookings, venues, customers, hosts, promos, feedback, admins + audit log
- `BillServlet`/`PdfBillServlet`, `NotificationServlet`, `ContactServlet`, password-reset flow

---

## 📄 Frontend - JSP Pages (30 files)

### Public Pages (`src/main/webapp/`)

- `index.jsp` — home: hero search, live stats, popular venues, about, contact form
- `login.jsp` — role-aware admin/customer/host login, validation, error display
- `register.jsp` — registration with client + server validation
- `forgot-password.jsp` / `reset-password.jsp` — self-service password reset flow
- `venues.jsp` — listing with AJAX filters (`#venueFilterForm`), pagination, multi-select, ratings
- `venue-details.jsp` — details, availability calendar, reviews, photo lightbox
- `booking.jsp` — booking form with live price estimate + inline validation
- `booking-multi.jsp` — multi-venue booking

### Protected Pages (role-checked, session required)

- `customer/`: `dashboard.jsp`, `bookings.jsp`, `booking-edit.jsp`,
  `bill.jsp`, `feedback.jsp`, `notifications.jsp`
- `admin/`: `dashboard.jsp`, `bookings.jsp`, `venues.jsp`, `venue-form.jsp`, `customers.jsp`,
  `hosts.jsp`, `promos.jsp`, `admins.jsp`, `analytics.jsp`, `notifications.jsp`
- `host/`: `dashboard.jsp`, `venue-form.jsp`, `notifications.jsp`

### Error Pages

```
└── error/
    ├── 404.jsp (1.3 KB) - PAGE NOT FOUND
    │   ├── 404 error message
    │   ├── Explanation text
    │   └── Link to home page
    │
    └── 500.jsp (1.3 KB) - SERVER ERROR
        ├── 500 error message
        ├── Explanation text
        └── Link to home page
```

---

## 🎨 Frontend Assets

### CSS

```
src/main/webapp/css/
└── style.css (~75 KB)
    ├── CSS Variables, base styles, navigation, buttons, forms, alerts, cards, grid
    ├── Hero section, venue cards, footer, admin/customer dashboards, bills, calendar
    ├── Toasts, in-page confirm modal, lightbox, skeleton loaders, field errors
    ├── :focus-visible rings, prefers-reduced-motion, responsive @media queries
src/main/webapp/images/
├── eventsphere-logo.svg — vector navbar logo (recreated banquet emblem, white backdrop)
├── eventsphere-icon.svg — emblem-only SVG favicon
├── EventSphere Logo.png — original artwork (kept for the print invoice)
└── venue photos (.jpg) + EventSphere background.png
```

### JavaScript

```
src/main/webapp/js/
└── script.js (~21 KB)
    ├── Validation (validateEmail/validatePassword/validateForm/validateLoginForm,
    │   validateBookingForm with per-field errors + esSetFieldError/esClearFieldError)
    ├── Live booking price estimate (esUpdatePriceEstimate, INR formatting)
    ├── Venue search (searchVenues, getVenuesUrl, clearFilters) + AJAX search
    │   with skeletons (esAjaxVenueSearch)
    ├── In-page confirm modal (esShowConfirm/esInterceptConfirm; confirmDelete,
    │   confirmAction, logout) — no native confirm()/alert(); toast fallback (showToast)
    ├── Lightbox (esOpenLightbox), multi-booking helpers, loading states (setLoadingState),
    │   navbar scroll effect, alert-close handlers, DOMContentLoaded wiring
    ├── Date Picker Setup (initializeDatePicker), Currency/Date Formatting,
    │   Element Visibility Toggle (toggleElement)
```

---

## ⚙️ Configuration Files

### Web Application Configuration

```
src/main/webapp/WEB-INF/
└── web.xml (1.1 KB)
    ├── App display name: EventSphere
    ├── Welcome file: index.jsp
    ├── Session configuration
    │   ├── Cookie settings (HttpOnly, Secure flags)
    │   ├── Tracking mode: COOKIE
    │   └── Timeout: 30 minutes
    ├── Error page mapping (404, 500)
    └── Jakarta EE 6.0 namespace
```

### Build Configuration

```
pom.xml
├── Project metadata
│   ├── groupId: com.eventsphere
│   ├── artifactId: event-sphere
│   ├── version: 1.0.3
│   ├── packaging: war
│   └── Java source/target: 25
│
├── Dependencies
│   ├── Jakarta Servlet API 6.1.0
│   ├── Jakarta JSP API 4.0.0
│   ├── PostgreSQL JDBC Driver 42.7.3
│   ├── BCrypt 0.10.2, HikariCP, Logback/SLF4J, JSTL
│   ├── Jakarta JSON 2.1.3
│   ├── Jakarta JSON-B 3.0.0
│   ├── Jakarta Mail, Flyway
│   └── JUnit 5 + Mockito + Testcontainers + Spring Test (test scope)
│
├── Plugins
│   ├── Maven Compiler Plugin (3.14.0)
│   ├── Maven WAR Plugin (3.4.0) → finalName EventSphere
│   ├── Flyway Maven Plugin (10.12.0)
│   └── Maven Surefire Plugin
│
└── Properties
    ├── Source encoding: UTF-8
    ├── Compiler source/target: 25
```

---

## 📊 Database Files

### Schema & Data

```
database.sql
├── 13 tables: admin_users, customer_users, host_users (BCrypt password_hash),
│   venues, events, bookings, bills, feedback, password_resets, notifications,
│   login_tokens, promocodes, audit_logs
├── Indexes + foreign keys + sample data (admin user, venues, events, bookings)
```

---

## 📦 Build Output Notes

The project build artifacts such as compiled classes and generated WAR files are produced locally by Maven and should not be committed as part of the source repository. The live source tree is represented by the Java, JSP, CSS, JavaScript, SQL, and documentation files listed above.

---

## 📋 Summary Statistics

### Code Metrics

| Category | Count | Notes |
|----------|-------|-------|
| Java Classes | 53 | model, dao, servlet, controller, filter, util |
| JSP Pages | 30 | public + customer + admin + host + error |
| CSS Files | 1 | ~75 KB (theme, dashboards, modal, lightbox, skeletons) |
| JavaScript Files | 1 | ~21 KB (validation, AJAX search, modal, lightbox) |
| Images | 17 | venue photos, background, vector logo + favicon, original PNG |
| SQL Schema | 1 | 13 tables + sample data |
| Documentation | 4 | README, SETUP_GUIDE, PROJECT_SUMMARY, FILE_MANIFEST |

### Feature Count

| Feature | Count |
|---------|-------|
| Database Tables | 13 |
| Servlet + Controller handlers | ~25 |
| DAO Classes | 12 |
| Model Classes | 9 |
| JSP Pages | 30 |
| API Endpoints | 25+ |

---

## 🔍 File Dependencies

```
index.jsp
├── Calls: /login, /register, /logout
├── Uses: css/style.css, js/script.js
└── Session: checks user authentication

register.jsp
├── Servlet: RegisterServlet
├── Uses: css/style.css, js/script.js
├── DAO: UserDAO (via servlet)
└── Model: User (via servlet)

login.jsp
├── Servlet: LoginServlet
├── Uses: css/style.css, js/script.js
├── DAO: UserDAO (via servlet)
└── Model: User (via servlet)

venues.jsp
├── Servlet: VenueServlet
├── Uses: css/style.css, js/script.js
├── DAO: VenueDAO (via servlet)
└── Model: Venue (via servlet)

Servlets
├── UserDAO → User model
├── VenueDAO → Venue model
├── EventDAO → Event model
├── BookingDAO → Booking model
├── FeedbackDAO → Feedback model
└── DBUtil (all DAOs depend on this)

DAO Classes
├── DBUtil → All DAOs use this
└── Models → DAOs map ResultSet to model objects
```

---

## ✅ File Verification

All files created and verified:

- ✅ 53 Java classes + 30 JSP pages present
- ✅ Configuration files present
- ✅ Database schema complete (13 tables)
- ✅ Documentation comprehensive
- ✅ Maven build structure correct
- ✅ Jakarta Servlet imports used (not javax)
- ✅ PostgreSQL syntax only (not MySQL)
- ✅ DB credentials via env vars (no hardcoded production secrets)
- ✅ All Java classes compiled successfully
- ✅ All JSP files syntax valid

---

## 📝 Notes

1. All Java source files use UTF-8 encoding
2. All SQL follows PostgreSQL syntax
3. No MySQL-specific features used
4. Role-aware `admin_users`, `customer_users` and `host_users` tables with BCrypt `password_hash` (cost 12)
5. Jakarta Servlet 6.1 for Tomcat 11 compatibility
6. Compiled classes ready for WAR packaging
7. External dependencies managed by Maven
8. Static assets (CSS/JS) not minified for readability

---

**Last Updated**: October 14, 2026
**Project Status**: ✅ Complete and Ready for Deployment
