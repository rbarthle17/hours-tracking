-- ============================================================================
-- V3: Move contract_id from time_entries to tickets
--
-- Tickets now belong to a contract (not directly to a client).
-- Client is derived via contracts.client_id.
-- Time entries inherit their contract through their ticket.
-- ============================================================================

-- Step 1: Add contract_id column to tickets (nullable initially for migration)
ALTER TABLE tickets
    ADD COLUMN contract_id INT UNSIGNED NULL AFTER id;

-- Step 2: Populate tickets.contract_id from the most-used contract in each
-- ticket's time entries (picks the contract with the most entries per ticket)
UPDATE tickets t
    JOIN (
        SELECT sub.ticket_id, MIN(sub.contract_id) AS contract_id
        FROM (
            SELECT ticket_id, contract_id,
                   COUNT(*) AS cnt
            FROM time_entries
            GROUP BY ticket_id, contract_id
        ) sub
        JOIN (
            SELECT ticket_id, MAX(cnt) AS max_cnt
            FROM (
                SELECT ticket_id, contract_id, COUNT(*) AS cnt
                FROM time_entries
                GROUP BY ticket_id, contract_id
            ) inner_sub
            GROUP BY ticket_id
        ) best ON sub.ticket_id = best.ticket_id AND sub.cnt = best.max_cnt
        GROUP BY sub.ticket_id
    ) winner ON t.id = winner.ticket_id
SET t.contract_id = winner.contract_id;

-- Step 3: For tickets with NO time entries, assign first active contract
-- for the ticket's client
UPDATE tickets t
    JOIN (
        SELECT c.client_id, MIN(c.id) AS fallback_contract_id
        FROM contracts c
        WHERE c.status = 'active'
        GROUP BY c.client_id
    ) fc ON t.client_id = fc.client_id
SET t.contract_id = fc.fallback_contract_id
WHERE t.contract_id IS NULL;

-- Step 3b: If still NULL (no active contract), use any contract for that client
UPDATE tickets t
    JOIN (
        SELECT c.client_id, MIN(c.id) AS fallback_contract_id
        FROM contracts c
        GROUP BY c.client_id
    ) fc ON t.client_id = fc.client_id
SET t.contract_id = fc.fallback_contract_id
WHERE t.contract_id IS NULL;

-- Step 4: Make contract_id NOT NULL, add FK and index
ALTER TABLE tickets
    MODIFY COLUMN contract_id INT UNSIGNED NOT NULL,
    ADD INDEX idx_tickets_contract (contract_id),
    ADD CONSTRAINT fk_tickets_contract
        FOREIGN KEY (contract_id) REFERENCES contracts(id) ON DELETE RESTRICT;

-- Step 5: Drop client_id FK, index, and column from tickets
ALTER TABLE tickets
    DROP FOREIGN KEY tickets_ibfk_1,
    DROP INDEX idx_tickets_client,
    DROP COLUMN client_id;

-- Step 6: Drop contract_id FK, index, and column from time_entries
ALTER TABLE time_entries
    DROP FOREIGN KEY time_entries_ibfk_2,
    DROP INDEX idx_time_entries_contract,
    DROP COLUMN contract_id;
