# Hours Tracking App

## Tech Stack
- ColdBox 8 (Lucee 6), MySQL 8, Bootstrap 5 + Alpine.js
- Server: `box server start` at http://127.0.0.1:51717
- DB: `hours_tracking`, user `cfuser`, password `cfpassword`

## Code Style (Non-Negotiable)
- Backend (handlers, services, models, config): Pure CFSCRIPT — no tags
- Frontend (views, layouts): HTML with CFML tags (`<cfoutput>`, `<cfloop>`, `<cfif>`)
- SQL: Always explicit column names — never `SELECT *`
- All dynamic values use `cfsqltype` params in `queryExecute()`
- No column-alignment whitespace in structs — single space between attributes
- Interview-quality code: clean naming, consistent patterns, proper separation of concerns

## Architecture
- Services are singletons in `models/services/`, own all SQL, return query objects
- Handlers are thin — delegate to service, set view, flash messages for feedback
- WireBox scans `models.services` (configured in `config/WireBox.cfc`); do NOT use `@services` suffix on inject annotations
- Use `provider:` prefix for circular dependency injection (e.g., AuthService ↔ UserService)
- `_method` hidden field for PUT/DELETE HTTP method spoofing
- Session-based auth; `Main.onRequestStart` checks `session.user` and redirects to login
- Public routes listed in `Main.cfc` `this.PUBLIC_ROUTES` array

## Key Gotchas
- BCrypt is NOT available in Lucee 6 — use SHA-512 with per-user salt (`hash(pw & salt, "SHA-512", "UTF-8", 128)`)
- After changing `.env`, run `box server restart` for Lucee to pick up new values
- `box cfconfig import .cfconfig.json` applies datasource config to running server
- Test `Application.cfc` needs `this.datasource = "hours_tracking"` for DB access
- ColdBox routes are order-dependent — custom routes (e.g., `/invoices/:id/send`) must come BEFORE `resources()` calls

## Testing
- `box testbox run` — runs all specs via TestBox BDD
- Integration tests simulate auth by setting `session.user` struct in `beforeEach`
- Test specs live in `tests/specs/integration/` and `tests/specs/unit/`

## Data Model
- Tickets belong to clients (not contracts) — survive contract renewals
- Time entries reference both `ticket_id` (what work) and `contract_id` (what rate)
- Invoice line items snapshot rate from contract at creation time
- Payments auto-update invoice status via `InvoiceService.recalculateStatus()`
