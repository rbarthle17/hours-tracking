-- Expense tracking table
-- Tracks business expenses, both general and client-associated.
-- is_billable flags expenses to surface when creating client invoices.
-- is_invoiced reserved for future invoice line item integration.

CREATE TABLE expenses (
    id                INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    client_id         INT UNSIGNED NULL,
    expense_date      DATE NOT NULL,
    vendor            VARCHAR(255) NOT NULL,
    amount            DECIMAL(10,2) NOT NULL,
    category          VARCHAR(100) NOT NULL,
    description       TEXT NULL,
    receipt_reference VARCHAR(255) NULL,
    is_billable       BOOLEAN NOT NULL DEFAULT FALSE,
    is_invoiced       BOOLEAN NOT NULL DEFAULT FALSE,
    created_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_expenses_client FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE RESTRICT,
    INDEX idx_expense_date (expense_date),
    INDEX idx_client_id (client_id),
    INDEX idx_category (category),
    INDEX idx_billable (is_billable, is_invoiced)
);
