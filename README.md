# YachtLife

A comprehensive yacht share/syndicate management platform for managing yacht ownership, bookings, maintenance, and financial operations.

## 🚀 Current Status

**Phase**: Architecture & Planning ✅ COMPLETE

**Next Step**: Begin implementation - Set up project structure, Docker, and backend foundation

**Ready to build**: All architecture, database schema, API design, and tech stack decisions are finalized.

---

## Overview

YachtLife facilitates the management of yacht syndicates by connecting management companies with yacht owners. The platform handles scheduling, invoicing, payments, maintenance logging, and governance through a mobile-first experience.

### Platform Components

```
┌────────────────────────────────────────────────────────────┐
│                      YachtLife Platform                    │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  📱 Mobile App (React Native)    🖥️  Web Dashboard (React) │
│  ├─ Apple Sign In                ├─ Email/Password Login  │
│  ├─ Vessel Dashboard             ├─ Fleet Management      │
│  ├─ Booking Management           ├─ Master Calendar       │
│  ├─ Invoice Payment              ├─ Invoice Creation      │
│  ├─ Logbook Entries              ├─ Analytics & Reports   │
│  ├─ Checklists                   ├─ Owner Management      │
│  └─ Voting                       └─ Notifications         │
│                                                            │
│              ⬇️  Shared API Backend (Go/Gin)  ⬇️            │
│                                                            │
│  🗄️  PostgreSQL  |  📦 Redis  |  💾 MinIO/S3              │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

## Features

### Management Company Features (Web Dashboard)
- **Dashboard Overview**:
  - Fleet overview with all vessels
  - Active bookings timeline
  - Revenue and expense tracking
  - Upcoming maintenance alerts
  - Recent activity feed
- **Vessel Management**:
  - Add/edit vessel details and specifications
  - Upload vessel images and documentation
  - Track engine hours and maintenance schedules
  - Set maintenance reminders
  - Document storage (manuals, insurance, certifications)
- **Owner Management**:
  - View all syndicate members
  - Manage ownership shares and allocations
  - Track days used vs. days allocated
  - View owner contact information
  - Send individual or bulk notifications
- **Booking Management**:
  - Master calendar view (all vessels)
  - Approve/reject booking change requests
  - Override or adjust bookings
  - Set blackout dates for maintenance
  - View booking history and patterns
- **Financial Management**:
  - Create and send invoices to owners
  - Track payment status (paid, pending, overdue)
  - Expense tracking (fuel, maintenance, marina fees)
  - Generate financial reports
  - Export data to CSV/PDF
  - Revenue forecasting
- **Maintenance & Logbook**:
  - Review all logbook entries
  - Track fuel consumption across fleet
  - Schedule preventive maintenance
  - Maintenance history and costs
  - Service provider management
- **Voting & Governance**:
  - Create polls and proposals
  - Set voting periods
  - Real-time voting results
  - Voting history and outcomes
- **Reporting & Analytics**:
  - Usage statistics per vessel
  - Owner utilization reports
  - Financial summaries (monthly, quarterly, annual)
  - Maintenance cost analysis
  - Fuel efficiency tracking
  - Custom report builder
- **Notifications & Communications**:
  - Send announcements to all owners
  - Automated reminders (bookings, payments, maintenance)
  - Email and push notification management
- **System Administration**:
  - User role management (admin, manager, owner)
  - System settings and configuration
  - Audit logs
  - Data backup and export

### Owner Features
- **Authentication**:
  - Sign in with Apple (primary auth method)
  - Select vessel and country on first login
  - Seamless single sign-on experience
- **Vessel Dashboard**:
  - Beautiful hero image of the yacht
  - Key vessel specifications (engines, hull ID, registration)
  - Quick stats overview
- **Booking Management**:
  - View current and upcoming bookings
  - Make new bookings
  - Cancel bookings
  - Propose booking changes
  - Allocate standby days
- **Financial**:
  - View invoices
  - Pay invoices via Apple Pay / Google Pay
  - View payment history
- **Logging**:
  - Fuel consumption logging
  - General logbook entries
  - Pre-departure checklist
  - Return/entry checklist
- **Voting**: Participate in syndicate decisions
- **Notifications**: Receive booking confirmations, reminders, and announcements

## User Experience Flow

### Authentication & Onboarding
1. **Launch Screen**: User opens the app
2. **Sign In Screen**:
   - Clean, minimal design
   - Large "Sign in with Apple" button
   - No traditional email/password fields
3. **Onboarding** (first-time users only):
   - **Step 1**: Select your vessel from a dropdown/picker
   - **Step 2**: Select your country
   - Welcome message and quick tutorial (optional)
4. **Redirect to Vessel Dashboard**

### Vessel Dashboard (Landing Page)
The landing page showcases the beauty and specs of the yacht:

```
┌─────────────────────────────────────┐
│                                     │
│     [HERO IMAGE OF VESSEL]          │
│     Beautiful full-width photo      │
│                                     │
├─────────────────────────────────────┤
│  VESSEL NAME                        │
│  Manufacturer | Model | Year        │
├─────────────────────────────────────┤
│  Quick Stats Cards (2x2 grid)       │
│  ┌──────────┐  ┌──────────┐        │
│  │ Engine   │  │  Speed   │        │
│  │ 2 x 450HP│  │ 35 knots │        │
│  └──────────┘  └──────────┘        │
│  ┌──────────┐  ┌──────────┐        │
│  │ Length   │  │  Year    │        │
│  │ 52 feet  │  │  2018    │        │
│  └──────────┘  └──────────┘        │
├─────────────────────────────────────┤
│  Vessel Details                     │
│  • Hull ID: ABC123XYZ456            │
│  • Registration: YCH-2018-123       │
│  • Country: Australia               │
│  • Home Port: Gold Coast            │
│  • Engine Hours: 1,247.5 hrs        │
├─────────────────────────────────────┤
│  [View Full Specs] [Bookings]      │
└─────────────────────────────────────┘
```

### Navigation
Bottom tab navigation:
- **Dashboard** (Home with vessel image & stats)
- **Bookings** (Calendar view)
- **Logbook** (Fuel, maintenance entries)
- **Invoices** (Financial)
- **More** (Settings, voting, profile)

## Architecture

### High-Level Architecture

```
┌─────────────────┐         ┌─────────────────┐
│  Mobile Apps    │         │   Web Dashboard │
│ (iOS & Android) │         │     (React)     │
│  React Native   │         │  Management Co. │
│   (Owners)      │         │  (Admin/Manager)│
└────────┬────────┘         └────────┬────────┘
         │                           │
         │         HTTPS/REST API    │
         └───────────┬───────────────┘
                     │
            ┌────────▼────────┐
            │   API Gateway   │
            │   (Go/Gin)      │
            └────────┬────────┘
                     │
                ┌────┴────┐
                │         │
            ┌───▼───┐ ┌──▼──────┐
            │  Auth │ │ Business│
            │Service│ │ Logic   │
            └───┬───┘ └──┬──────┘
                │        │
                │   ┌────▼─────┐
                │   │PostgreSQL│
                │   │ Database │
                │   └────┬─────┘
                │        │
            ┌───▼────────▼───┐
            │  Redis Cache   │
            └────────────────┘

External Services:
- Apple Sign In (Mobile authentication)
- Stripe (Payment Processing for Apple/Google Pay)
- Firebase Cloud Messaging (Push Notifications)
- AWS S3 / MinIO (Document & Image Storage)
- SendGrid / AWS SES (Email notifications)
```

### Tech Stack

#### Mobile App (Owners)
- **Framework**: React Native
- **State Management**: Zustand
- **Navigation**: React Navigation
- **UI Components**: React Native Paper / Native Base
- **Payment**: Stripe SDK (Apple Pay & Google Pay)
- **Forms**: React Hook Form
- **HTTP Client**: Axios

#### Web Dashboard (Management)
- **Framework**: React 18+ with TypeScript
- **Build Tool**: Vite
- **State Management**: Zustand
- **Routing**: React Router v6
- **UI Library**: Material-UI (MUI) or Ant Design
- **Data Visualization**: Recharts / Chart.js
- **Tables**: TanStack Table (React Table)
- **Forms**: React Hook Form + Zod validation
- **Date Handling**: date-fns
- **HTTP Client**: Axios
- **Authentication**: JWT tokens (email/password for managers)

#### Backend
- **Language**: Go 1.21+
- **Framework**: Gin
- **ORM**: GORM
- **Authentication**: Apple Sign In (OAuth 2.0) + JWT tokens for session management
- **Validation**: go-playground/validator
- **Documentation**: Swagger/OpenAPI

#### Database
- **Primary Database**: PostgreSQL 15+
  - **Why PostgreSQL over MongoDB**:
    - Better for financial data (ACID compliance)
    - Superior for reporting and statistics (complex JOINs, aggregations)
    - Strong data integrity constraints
    - Mature ecosystem for analytics
    - Better performance for complex queries
    - Support for both relational and JSON data (JSONB)
- **Cache**: Redis
- **File Storage**: MinIO (S3-compatible) or AWS S3

#### Infrastructure
- **Containerization**: Docker & Docker Compose
- **API Documentation**: Swagger UI
- **CI/CD**: GitHub Actions
- **Monitoring**: Prometheus + Grafana (future)

## Database Schema

### Core Tables

#### users
```sql
- id (uuid, primary key)
- apple_user_id (varchar, unique) -- Apple Sign In identifier
- email (varchar, unique)
- first_name (varchar)
- last_name (varchar)
- phone (varchar)
- country (varchar) -- Selected during onboarding
- role (enum: 'admin', 'manager', 'owner')
- profile_image_url (varchar)
- created_at (timestamp)
- updated_at (timestamp)
- deleted_at (timestamp, soft delete)
```

#### yachts
```sql
- id (uuid, primary key)
- name (varchar)
- manufacturer (varchar)
- model (varchar)
- year (integer)
- length_feet (decimal)
- beam_feet (decimal)
- draft_feet (decimal)
- hull_id (varchar, unique) -- Similar to VIN for vehicles (HIN - Hull Identification Number)
- registration (varchar)
- registration_country (varchar)
- home_port (varchar)
- max_passengers (integer)
- cruising_speed_knots (decimal)
- max_speed_knots (decimal)
- fuel_capacity_liters (decimal)
- water_capacity_liters (decimal)
- engine_make (varchar)
- engine_model (varchar)
- engine_count (integer)
- engine_horsepower (integer)
- engine_hours (decimal)
- transmission_type (varchar)
- hero_image_url (varchar) -- Main beautiful image for landing page
- gallery_images (jsonb) -- Array of additional images
- specifications (jsonb) -- Additional flexible specs
- created_at (timestamp)
- updated_at (timestamp)
```

#### syndicate_shares
```sql
- id (uuid, primary key)
- yacht_id (uuid, foreign key -> yachts.id)
- user_id (uuid, foreign key -> users.id)
- share_percentage (decimal)
- days_per_year (integer)
- standby_days_remaining (integer)
- joined_date (date)
- created_at (timestamp)
- updated_at (timestamp)
```

#### bookings
```sql
- id (uuid, primary key)
- yacht_id (uuid, foreign key -> yachts.id)
- user_id (uuid, foreign key -> users.id)
- start_date (timestamp)
- end_date (timestamp)
- status (enum: 'pending', 'confirmed', 'cancelled', 'completed')
- booking_type (enum: 'regular', 'standby')
- is_standby (boolean)
- notes (text)
- created_at (timestamp)
- updated_at (timestamp)
- cancelled_at (timestamp)
```

#### booking_change_requests
```sql
- id (uuid, primary key)
- booking_id (uuid, foreign key -> bookings.id)
- requested_by (uuid, foreign key -> users.id)
- proposed_start_date (timestamp)
- proposed_end_date (timestamp)
- reason (text)
- status (enum: 'pending', 'approved', 'rejected')
- created_at (timestamp)
- updated_at (timestamp)
```

#### invoices
```sql
- id (uuid, primary key)
- yacht_id (uuid, foreign key -> yachts.id)
- user_id (uuid, foreign key -> users.id)
- invoice_number (varchar, unique)
- description (text)
- amount (decimal)
- due_date (date)
- status (enum: 'draft', 'sent', 'paid', 'overdue', 'cancelled')
- issued_date (date)
- paid_date (date)
- created_at (timestamp)
- updated_at (timestamp)
```

#### payments
```sql
- id (uuid, primary key)
- invoice_id (uuid, foreign key -> invoices.id)
- user_id (uuid, foreign key -> users.id)
- amount (decimal)
- payment_method (enum: 'apple_pay', 'google_pay', 'card')
- stripe_payment_id (varchar)
- status (enum: 'pending', 'completed', 'failed', 'refunded')
- paid_at (timestamp)
- created_at (timestamp)
```

#### logbook_entries
```sql
- id (uuid, primary key)
- yacht_id (uuid, foreign key -> yachts.id)
- booking_id (uuid, foreign key -> bookings.id)
- user_id (uuid, foreign key -> users.id)
- entry_type (enum: 'fuel', 'maintenance', 'general', 'incident')
- fuel_liters (decimal, nullable)
- fuel_cost (decimal, nullable)
- hours_operated (decimal, nullable)
- notes (text)
- created_at (timestamp)
```

#### checklists
```sql
- id (uuid, primary key)
- booking_id (uuid, foreign key -> bookings.id)
- checklist_type (enum: 'pre_departure', 'return')
- completed (boolean)
- completed_at (timestamp)
- completed_by (uuid, foreign key -> users.id)
- items (jsonb)  -- Flexible checklist items
- created_at (timestamp)
- updated_at (timestamp)
```

#### votes
```sql
- id (uuid, primary key)
- yacht_id (uuid, foreign key -> yachts.id)
- created_by (uuid, foreign key -> users.id)
- title (varchar)
- description (text)
- vote_type (enum: 'yes_no', 'multiple_choice')
- options (jsonb)
- start_date (timestamp)
- end_date (timestamp)
- status (enum: 'draft', 'active', 'closed')
- created_at (timestamp)
- updated_at (timestamp)
```

#### vote_responses
```sql
- id (uuid, primary key)
- vote_id (uuid, foreign key -> votes.id)
- user_id (uuid, foreign key -> users.id)
- response (jsonb)
- voted_at (timestamp)
- created_at (timestamp)
```

### Indexes
- users: email, role
- bookings: yacht_id, user_id, start_date, end_date, status
- invoices: user_id, yacht_id, status, due_date
- logbook_entries: yacht_id, booking_id, entry_type, created_at
- syndicate_shares: yacht_id, user_id

## API Design

### Authentication
**Mobile (Owners)**
- `POST /api/v1/auth/apple` - Authenticate with Apple Sign In token
- `POST /api/v1/auth/onboard` - Complete onboarding (select vessel & country)
- `POST /api/v1/auth/refresh` - Refresh JWT token
- `POST /api/v1/auth/logout` - Logout
- `GET /api/v1/auth/vessels` - List available vessels for selection during onboarding

**Web (Management)**
- `POST /api/v1/auth/login` - Login with email/password (managers/admins)
- `POST /api/v1/auth/register` - Register new manager account (admin only)
- `POST /api/v1/auth/refresh` - Refresh JWT token
- `POST /api/v1/auth/logout` - Logout
- `POST /api/v1/auth/reset-password` - Request password reset
- `POST /api/v1/auth/verify-reset-token` - Verify reset token and set new password

### Users
- `GET /api/v1/users/me` - Get current user profile
- `PUT /api/v1/users/me` - Update profile
- `GET /api/v1/users/:id` - Get user by ID (admin/manager only)

### Yachts
- `GET /api/v1/yachts` - List all yachts
- `GET /api/v1/yachts/:id` - Get yacht details with full specifications
- `GET /api/v1/yachts/:id/dashboard` - Get yacht dashboard data (hero image, stats, quick info)
- `POST /api/v1/yachts` - Create yacht (manager only)
- `PUT /api/v1/yachts/:id` - Update yacht (manager only)
- `PUT /api/v1/yachts/:id/engine-hours` - Update engine hours
- `POST /api/v1/yachts/:id/images` - Upload yacht images

### Bookings
- `GET /api/v1/bookings` - List bookings (filtered by user)
- `GET /api/v1/bookings/:id` - Get booking details
- `POST /api/v1/bookings` - Create booking
- `PUT /api/v1/bookings/:id` - Update booking
- `DELETE /api/v1/bookings/:id` - Cancel booking
- `POST /api/v1/bookings/:id/change-request` - Propose booking change
- `GET /api/v1/yachts/:id/availability` - Check yacht availability

### Invoices
- `GET /api/v1/invoices` - List invoices (filtered by user)
- `GET /api/v1/invoices/:id` - Get invoice details
- `POST /api/v1/invoices` - Create invoice (manager only)
- `PUT /api/v1/invoices/:id` - Update invoice (manager only)

### Payments
- `POST /api/v1/payments/create-intent` - Create Stripe payment intent
- `POST /api/v1/payments/confirm` - Confirm payment
- `GET /api/v1/payments/:id` - Get payment details

### Logbook
- `GET /api/v1/logbook` - List logbook entries
- `GET /api/v1/logbook/:id` - Get entry details
- `POST /api/v1/logbook` - Create logbook entry
- `PUT /api/v1/logbook/:id` - Update entry
- `GET /api/v1/yachts/:id/fuel-stats` - Get fuel consumption statistics

### Checklists
- `GET /api/v1/checklists/booking/:booking_id` - Get checklists for booking
- `POST /api/v1/checklists` - Create checklist
- `PUT /api/v1/checklists/:id` - Update checklist
- `POST /api/v1/checklists/:id/complete` - Mark checklist as complete

### Voting
- `GET /api/v1/votes` - List active votes
- `GET /api/v1/votes/:id` - Get vote details
- `POST /api/v1/votes` - Create vote (manager only)
- `PUT /api/v1/votes/:id` - Update vote (manager only)
- `DELETE /api/v1/votes/:id` - Delete vote (manager only)
- `POST /api/v1/votes/:id/respond` - Submit vote response
- `GET /api/v1/votes/:id/results` - Get vote results

### Analytics & Reports (Manager only)
- `GET /api/v1/analytics/dashboard` - Dashboard overview stats
- `GET /api/v1/analytics/vessels/:id/usage` - Vessel usage statistics
- `GET /api/v1/analytics/vessels/:id/revenue` - Revenue by vessel
- `GET /api/v1/analytics/owners/:id/utilization` - Owner utilization stats
- `GET /api/v1/analytics/financial-summary` - Financial summary report
- `GET /api/v1/analytics/maintenance-costs` - Maintenance cost analysis
- `POST /api/v1/analytics/export` - Export report to CSV/PDF

### Syndicate Shares (Manager only)
- `GET /api/v1/syndicate-shares` - List all shares
- `POST /api/v1/syndicate-shares` - Create new share allocation
- `PUT /api/v1/syndicate-shares/:id` - Update share
- `DELETE /api/v1/syndicate-shares/:id` - Remove share

### Notifications (Manager only)
- `POST /api/v1/notifications/broadcast` - Send notification to all owners
- `POST /api/v1/notifications/send` - Send notification to specific users
- `GET /api/v1/notifications/history` - View notification history

## Project Structure

```
YachtLife/
├── backend/
│   ├── cmd/
│   │   └── server/
│   │       └── main.go
│   ├── internal/
│   │   ├── api/
│   │   │   ├── handlers/
│   │   │   │   ├── auth.go
│   │   │   │   ├── users.go
│   │   │   │   ├── yachts.go
│   │   │   │   ├── bookings.go
│   │   │   │   ├── invoices.go
│   │   │   │   ├── payments.go
│   │   │   │   ├── logbook.go
│   │   │   │   ├── checklists.go
│   │   │   │   ├── votes.go
│   │   │   │   ├── analytics.go
│   │   │   │   ├── notifications.go
│   │   │   │   └── syndicate.go
│   │   │   ├── middleware/
│   │   │   │   ├── auth.go
│   │   │   │   ├── role.go (role-based access control)
│   │   │   │   ├── cors.go
│   │   │   │   └── logger.go
│   │   │   └── routes/
│   │   │       └── routes.go
│   │   ├── models/
│   │   │   ├── user.go
│   │   │   ├── yacht.go
│   │   │   ├── booking.go
│   │   │   ├── invoice.go
│   │   │   ├── payment.go
│   │   │   ├── logbook.go
│   │   │   ├── checklist.go
│   │   │   ├── vote.go
│   │   │   ├── syndicate_share.go
│   │   │   └── notification.go
│   │   ├── services/
│   │   │   ├── auth_service.go
│   │   │   ├── apple_auth_service.go
│   │   │   ├── booking_service.go
│   │   │   ├── payment_service.go
│   │   │   ├── notification_service.go
│   │   │   ├── analytics_service.go
│   │   │   ├── email_service.go
│   │   │   └── report_service.go
│   │   ├── repository/
│   │   │   ├── user_repository.go
│   │   │   ├── yacht_repository.go
│   │   │   ├── booking_repository.go
│   │   │   ├── invoice_repository.go
│   │   │   ├── payment_repository.go
│   │   │   ├── logbook_repository.go
│   │   │   └── analytics_repository.go
│   │   ├── config/
│   │   │   └── config.go
│   │   └── database/
│   │       ├── database.go
│   │       └── migrations/
│   ├── pkg/
│   │   ├── utils/
│   │   └── validator/
│   ├── Dockerfile
│   ├── go.mod
│   └── go.sum
├── mobile/                          (Owner App - React Native)
│   ├── src/
│   │   ├── screens/
│   │   │   ├── auth/
│   │   │   │   ├── SignInScreen.tsx
│   │   │   │   ├── OnboardingScreen.tsx (vessel & country selection)
│   │   │   │   └── AppleSignInButton.tsx
│   │   │   ├── dashboard/
│   │   │   │   ├── VesselDashboard.tsx (landing page with hero image)
│   │   │   │   └── SpecificationsCard.tsx
│   │   │   ├── bookings/
│   │   │   │   ├── BookingListScreen.tsx
│   │   │   │   ├── CreateBookingScreen.tsx
│   │   │   │   └── BookingDetailScreen.tsx
│   │   │   ├── invoices/
│   │   │   │   ├── InvoiceListScreen.tsx
│   │   │   │   ├── InvoiceDetailScreen.tsx
│   │   │   │   └── PaymentScreen.tsx
│   │   │   ├── logbook/
│   │   │   │   ├── LogbookListScreen.tsx
│   │   │   │   └── CreateLogEntryScreen.tsx
│   │   │   ├── checklists/
│   │   │   │   ├── ChecklistScreen.tsx
│   │   │   │   └── ChecklistFormScreen.tsx
│   │   │   └── voting/
│   │   │       ├── VoteListScreen.tsx
│   │   │       └── VoteDetailScreen.tsx
│   │   ├── components/
│   │   │   ├── VesselHeroImage.tsx
│   │   │   ├── SpecificationRow.tsx
│   │   │   ├── StatCard.tsx
│   │   │   └── BookingCalendar.tsx
│   │   ├── navigation/
│   │   ├── services/
│   │   │   ├── api.ts
│   │   │   ├── appleAuth.ts
│   │   │   └── payment.ts
│   │   ├── stores/
│   │   │   ├── authStore.ts
│   │   │   ├── vesselStore.ts
│   │   │   └── bookingStore.ts
│   │   ├── types/
│   │   └── utils/
│   ├── android/
│   ├── ios/
│   ├── package.json
│   └── tsconfig.json
├── web/                             (Management Dashboard - React)
│   ├── public/
│   ├── src/
│   │   ├── pages/
│   │   │   ├── auth/
│   │   │   │   ├── LoginPage.tsx
│   │   │   │   └── ForgotPasswordPage.tsx
│   │   │   ├── dashboard/
│   │   │   │   └── DashboardPage.tsx (overview stats & charts)
│   │   │   ├── vessels/
│   │   │   │   ├── VesselListPage.tsx
│   │   │   │   ├── VesselDetailPage.tsx
│   │   │   │   ├── CreateVesselPage.tsx
│   │   │   │   └── EditVesselPage.tsx
│   │   │   ├── owners/
│   │   │   │   ├── OwnerListPage.tsx
│   │   │   │   ├── OwnerDetailPage.tsx
│   │   │   │   └── ManageSharesPage.tsx
│   │   │   ├── bookings/
│   │   │   │   ├── BookingCalendarPage.tsx (master calendar)
│   │   │   │   ├── BookingListPage.tsx
│   │   │   │   └── BookingRequestsPage.tsx
│   │   │   ├── financial/
│   │   │   │   ├── InvoicesPage.tsx
│   │   │   │   ├── CreateInvoicePage.tsx
│   │   │   │   ├── PaymentsPage.tsx
│   │   │   │   └── ExpensesPage.tsx
│   │   │   ├── maintenance/
│   │   │   │   ├── MaintenanceSchedulePage.tsx
│   │   │   │   ├── LogbookReviewPage.tsx
│   │   │   │   └── ServiceHistoryPage.tsx
│   │   │   ├── voting/
│   │   │   │   ├── VoteListPage.tsx
│   │   │   │   ├── CreateVotePage.tsx
│   │   │   │   └── VoteResultsPage.tsx
│   │   │   ├── reports/
│   │   │   │   ├── ReportsPage.tsx
│   │   │   │   ├── FinancialReportsPage.tsx
│   │   │   │   ├── UsageReportsPage.tsx
│   │   │   │   └── CustomReportBuilder.tsx
│   │   │   ├── notifications/
│   │   │   │   ├── SendNotificationPage.tsx
│   │   │   │   └── NotificationHistoryPage.tsx
│   │   │   └── settings/
│   │   │       ├── SettingsPage.tsx
│   │   │       └── UserManagementPage.tsx
│   │   ├── components/
│   │   │   ├── layout/
│   │   │   │   ├── Sidebar.tsx
│   │   │   │   ├── Header.tsx
│   │   │   │   └── Layout.tsx
│   │   │   ├── charts/
│   │   │   │   ├── RevenueChart.tsx
│   │   │   │   ├── UsageChart.tsx
│   │   │   │   └── FuelConsumptionChart.tsx
│   │   │   ├── tables/
│   │   │   │   ├── DataTable.tsx
│   │   │   │   └── InvoiceTable.tsx
│   │   │   └── forms/
│   │   │       ├── VesselForm.tsx
│   │   │       ├── InvoiceForm.tsx
│   │   │       └── VoteForm.tsx
│   │   ├── services/
│   │   │   └── api.ts
│   │   ├── hooks/
│   │   ├── stores/
│   │   │   ├── authStore.ts
│   │   │   ├── vesselStore.ts
│   │   │   ├── bookingStore.ts
│   │   │   └── notificationStore.ts
│   │   ├── types/
│   │   ├── utils/
│   │   └── App.tsx
│   ├── index.html
│   ├── vite.config.ts
│   ├── package.json
│   └── tsconfig.json
├── docker-compose.yml
├── .env.example
├── .gitignore
└── README.md
```

## Implementation Plan

### Immediate Next Steps

We'll build this application in a structured, phased approach. Here's what we'll do first:

#### Step 1: Project Foundation (START HERE)
1. **Create project structure**
   - Set up `/backend`, `/mobile`, and `/web` directories
   - Initialize Go modules for backend
   - Initialize React Native project for mobile app
   - Initialize React + Vite project for web dashboard

2. **Docker infrastructure**
   - Create `docker-compose.yml` with PostgreSQL, Redis, and MinIO
   - Set up `.env.example` with all required environment variables
   - Configure network and volume mappings

3. **Backend scaffolding**
   - Set up Go/Gin server structure
   - Configure GORM with PostgreSQL
   - Create database migration system
   - Set up basic routing and middleware

4. **Database migrations**
   - Create all 11 core tables (users, yachts, bookings, invoices, etc.)
   - Set up indexes
   - Add seed data for testing

#### Step 2: Authentication System
1. **Backend authentication**
   - Implement Apple Sign In validation
   - Implement email/password for managers
   - JWT token generation and validation
   - Role-based access control middleware

2. **Mobile authentication screens**
   - Sign in with Apple button
   - Onboarding flow (vessel & country selection)
   - Token storage and refresh

3. **Web authentication screens**
   - Login page with email/password
   - Password reset flow
   - Session management

#### Step 3: Core Features (MVP)
1. **Vessel management**
   - Backend CRUD APIs
   - Web dashboard for vessel management
   - Mobile vessel dashboard with hero image

2. **Booking system**
   - Backend booking logic
   - Mobile booking screens
   - Web master calendar

3. **Basic invoicing**
   - Create invoices (web)
   - View and pay invoices (mobile with Stripe)

#### Step 4: Iteration
- Add remaining features (logbook, checklists, voting)
- Build analytics and reporting
- Polish UI/UX
- Testing and deployment

### Build Order Priority
1. ✅ Architecture & planning (COMPLETED)
2. 🎯 Project structure & Docker setup (NEXT)
3. 🎯 Backend foundation & auth
4. 🎯 Mobile app foundation
5. 🎯 Web dashboard foundation
6. 🎯 Vessel & booking features
7. 🎯 Financial features
8. 🎯 Logbook & checklists
9. 🎯 Voting & governance
10. 🎯 Analytics & reporting

## Development Roadmap

### Phase 1: Foundation (Weeks 1-2)
- [ ] Set up project structure (backend, mobile, web)
- [ ] Configure Docker environment (PostgreSQL, Redis, MinIO)
- [ ] Initialize Go backend with Gin
- [ ] Set up database migrations
- [ ] Implement authentication
  - [ ] Apple Sign In for mobile
  - [ ] Email/password for web dashboard
  - [ ] JWT token management
  - [ ] Role-based access control middleware
- [ ] Initialize React Native project (mobile)
- [ ] Initialize React + Vite project (web dashboard)
- [ ] Set up API client and Zustand state management for both frontends

### Phase 2: Core Booking System (Weeks 3-4)
- [ ] Implement yacht management (CRUD)
- [ ] Build booking system backend
  - [ ] Create booking
  - [ ] View bookings
  - [ ] Cancel booking
  - [ ] Booking change requests
  - [ ] Availability calendar logic
- [ ] Build mobile booking screens
  - [ ] Booking calendar view
  - [ ] Create/cancel booking
  - [ ] Booking change requests
- [ ] Build web booking management
  - [ ] Master calendar (all vessels)
  - [ ] Approve/reject change requests
  - [ ] Override bookings
  - [ ] Blackout dates
- [ ] Add push notifications for bookings

### Phase 3: Financial Management (Weeks 5-6)
- [ ] Invoice creation and management
- [ ] Stripe integration for payments
- [ ] Apple Pay / Google Pay implementation
- [ ] Payment history and receipts
- [ ] Build invoice screens
- [ ] Payment confirmation flow

### Phase 4: Logbook & Checklists (Week 7)
- [ ] Fuel logging system
- [ ] General logbook entries
- [ ] Pre-departure checklist
- [ ] Return checklist
- [ ] Build logbook screens
- [ ] Checklist UI components

### Phase 5: Voting & Governance (Week 8)
- [ ] Create voting system
- [ ] Vote creation (managers)
- [ ] Vote participation (owners)
- [ ] Results visualization
- [ ] Build voting screens

### Phase 6: Reporting & Analytics (Week 9)
- [ ] Analytics backend
  - [ ] Usage statistics
  - [ ] Fuel consumption analysis
  - [ ] Financial summaries
  - [ ] Owner utilization tracking
- [ ] Web dashboard analytics
  - [ ] Overview dashboard with charts
  - [ ] Revenue charts (Recharts)
  - [ ] Usage statistics visualizations
  - [ ] Custom report builder
  - [ ] Export to CSV/PDF
- [ ] Mobile stats views (simplified)

### Phase 7: Polish & Testing (Week 10)
- [ ] Comprehensive testing
- [ ] UI/UX refinements
- [ ] Performance optimization
- [ ] Security audit
- [ ] Documentation
- [ ] Beta testing

### Phase 8: Deployment
- [ ] Set up production infrastructure
- [ ] CI/CD pipeline
- [ ] App store submission (iOS)
- [ ] Play Store submission (Android)
- [ ] Production monitoring

## Getting Started

### Prerequisites
- Go 1.21+
- Node.js 18+
- Docker & Docker Compose
- React Native CLI
- Xcode (for iOS)
- Android Studio (for Android)

### Environment Setup

1. Clone the repository:
```bash
git clone https://github.com/bitcoinbrisbane/YachtLife.git
cd YachtLife
```

2. Set up environment variables:
```bash
cp .env.example .env
# Edit .env with your configuration
```

3. Start infrastructure:
```bash
docker-compose up -d
```

4. Run backend:
```bash
cd backend
go mod download
go run cmd/server/main.go
```

5. Run mobile app:
```bash
cd mobile
npm install
# For iOS
npx react-native run-ios
# For Android
npx react-native run-android
```

## Configuration

Key environment variables:
- `DATABASE_URL`: PostgreSQL connection string
- `REDIS_URL`: Redis connection string
- `JWT_SECRET`: Secret for JWT token signing
- `APPLE_TEAM_ID`: Apple Developer Team ID
- `APPLE_CLIENT_ID`: Apple Sign In Service ID
- `APPLE_KEY_ID`: Apple Sign In Key ID
- `APPLE_PRIVATE_KEY`: Apple Sign In private key
- `STRIPE_SECRET_KEY`: Stripe API key
- `STRIPE_PUBLISHABLE_KEY`: Stripe publishable key
- `S3_BUCKET`: S3/MinIO bucket name
- `S3_ENDPOINT`: S3/MinIO endpoint URL
- `FCM_SERVER_KEY`: Firebase Cloud Messaging key
- `SENDGRID_API_KEY`: SendGrid API key for emails
- `EMAIL_FROM`: From email address
- `CORS_ALLOWED_ORIGINS`: Comma-separated list of allowed origins

## Contributing

(Add contribution guidelines as project matures)

## License

(Specify license)

## Support

For issues and questions, please open an issue on GitHub.
