-- ============================================================================
-- Hours Tracking Application - Seed Data
-- ============================================================================
-- Default admin password: admin123
-- SHA-512 hash with unique salt. CHANGE THIS PASSWORD after first login.
INSERT INTO users (email, password_hash, salt, first_name, last_name, role, is_active)
VALUES ('admin@hourstrack.local', 'F210D421170443CE6A9992F63568F3187844A843A3D4F4A106985CF33D0EAFC92B8F8AC117040E453BE6A03A4C8477A90370D3961E992942F3D979326D5D4DC4', '505A772C-2736-4625-91D0D1ADAE739545', 'Admin', 'User', 'admin', TRUE);

-- Sample clients
INSERT INTO clients (name, email, phone, address) VALUES
('Acme Corporation', 'billing@acmecorp.com', '555-0100', '123 Main St, Suite 400\nAnytown, ST 12345'),
('TechStart Inc', 'accounts@techstart.io', '555-0200', '456 Innovation Blvd\nSilicon Valley, CA 94000'),
('Greenfield Solutions', 'ap@greenfieldsolutions.com', '555-0300', '789 Enterprise Way\nBoston, MA 02101');

-- Contracts
INSERT INTO contracts (client_id, name, hourly_rate, start_date, end_date, status) VALUES
(1, 'Acme Web Portal - Phase 1', 150.00, '2025-11-01', '2026-04-30', 'active'),
(1, 'Acme API Integration', 175.00, '2026-01-15', NULL, 'active'),
(2, 'TechStart MVP Build', 160.00, '2025-12-01', '2026-03-31', 'active'),
(3, 'Greenfield Legacy Migration', 140.00, '2025-10-01', '2025-12-31', 'completed');

-- Tickets
INSERT INTO tickets (client_id, title, description, status, priority) VALUES
(1, 'User authentication module', 'Implement login, registration, and password reset flows', 'in_progress', 'high'),
(1, 'Dashboard wireframes to HTML', 'Convert approved wireframes to responsive HTML/CSS', 'open', 'medium'),
(1, 'API endpoint - user profiles', 'REST endpoints for CRUD operations on user profiles', 'open', 'medium'),
(1, 'Payment gateway integration', 'Integrate Stripe for subscription billing', 'open', 'high'),
(2, 'MVP landing page', 'Build responsive landing page with signup form', 'done', 'high'),
(2, 'User onboarding flow', 'Multi-step onboarding wizard for new users', 'in_progress', 'medium'),
(2, 'Analytics dashboard', 'Charts and metrics for user engagement', 'open', 'low'),
(3, 'Database migration scripts', 'Migrate legacy Access DB to PostgreSQL', 'done', 'high');

-- Time entries (spread across Jan-Feb 2026)
INSERT INTO time_entries (ticket_id, contract_id, user_id, entry_date, hours_worked, notes) VALUES
-- Acme Web Portal work
(1, 1, 1, '2026-01-06', 6.00, 'Set up auth scaffolding, session management'),
(1, 1, 1, '2026-01-07', 7.50, 'Login/logout flow, password hashing'),
(1, 1, 1, '2026-01-08', 5.25, 'Registration form and validation'),
(2, 1, 1, '2026-01-09', 8.00, 'Dashboard layout, responsive grid'),
(2, 1, 1, '2026-01-10', 4.00, 'Chart components and data binding'),
-- Acme API work
(3, 2, 1, '2026-01-13', 6.50, 'API design and endpoint scaffolding'),
(3, 2, 1, '2026-01-14', 7.00, 'CRUD endpoints with validation'),
(4, 2, 1, '2026-01-15', 3.50, 'Stripe API research and sandbox setup'),
-- TechStart work
(5, 3, 1, '2026-01-20', 8.00, 'Landing page HTML/CSS from design comp'),
(5, 3, 1, '2026-01-21', 4.50, 'Signup form with email validation'),
(6, 3, 1, '2026-01-22', 6.00, 'Onboarding step 1-3 implementation'),
(6, 3, 1, '2026-01-23', 5.50, 'Onboarding step 4-5, progress tracking'),
-- February entries
(1, 1, 1, '2026-02-03', 7.00, 'Password reset flow with email tokens'),
(2, 1, 1, '2026-02-04', 6.50, 'Mobile responsive fixes for dashboard'),
(4, 2, 1, '2026-02-05', 8.00, 'Stripe checkout integration'),
(4, 2, 1, '2026-02-06', 5.00, 'Webhook handlers for payment events'),
(6, 3, 1, '2026-02-10', 7.00, 'Onboarding completion and analytics hooks'),
(7, 3, 1, '2026-02-11', 4.00, 'Analytics dashboard chart prototypes'),
-- Greenfield (completed contract)
(8, 4, 1, '2025-11-15', 8.00, 'Schema analysis and migration planning'),
(8, 4, 1, '2025-11-16', 8.00, 'Migration scripts and data validation');

-- Completed invoice for Greenfield
INSERT INTO invoices (client_id, invoice_number, invoice_date, due_date, total_amount, status, notes)
VALUES (3, 'INV-2025-0001', '2025-12-01', '2025-12-31', 2240.00, 'paid', 'Final invoice for legacy migration project');

-- Line items for Greenfield invoice
INSERT INTO invoice_line_items (invoice_id, contract_id, time_entry_id, hours, rate, description, subtotal)
VALUES
(1, 4, 19, 8.00, 140.00, 'Database migration scripts - Schema analysis and migration planning', 1120.00),
(1, 4, 20, 8.00, 140.00, 'Database migration scripts - Migration scripts and data validation', 1120.00);

-- Payment for Greenfield invoice
INSERT INTO payments (invoice_id, payment_date, amount, method, reference_number, notes)
VALUES (1, '2025-12-20', 2240.00, 'ach', 'ACH-20251220-001', 'Paid in full');

-- Draft invoice for Acme (January hours on Web Portal contract)
INSERT INTO invoices (client_id, invoice_number, invoice_date, due_date, total_amount, status, notes)
VALUES (1, 'INV-2026-0001', '2026-02-01', '2026-03-01', 4612.50, 'draft', 'January 2026 - Web Portal development');

-- Line items for Acme draft invoice
INSERT INTO invoice_line_items (invoice_id, contract_id, time_entry_id, hours, rate, description, subtotal)
VALUES
(2, 1, 1, 6.00, 150.00, 'User authentication module - Set up auth scaffolding', 900.00),
(2, 1, 2, 7.50, 150.00, 'User authentication module - Login/logout flow', 1125.00),
(2, 1, 3, 5.25, 150.00, 'User authentication module - Registration form', 787.50),
(2, 1, 4, 8.00, 150.00, 'Dashboard wireframes to HTML - Layout and grid', 1200.00),
(2, 1, 5, 4.00, 150.00, 'Dashboard wireframes to HTML - Chart components', 600.00);
