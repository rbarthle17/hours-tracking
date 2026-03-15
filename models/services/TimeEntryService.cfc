/**
 * TimeEntryService
 *
 * CRUD operations for time entry records.
 * Time entries link a user to a ticket. Contract and rate are inherited through the ticket.
 */
component singleton accessors="true" {

	/**
	 * List all time entries with joins, optionally filtered
	 *
	 * @contractId Optional contract ID filter
	 * @ticketId   Optional ticket ID filter
	 * @clientId   Optional client ID filter
	 * @startDate  Optional start date filter
	 * @endDate    Optional end date filter
	 *
	 * @return query
	 */
	function list(
		numeric contractId = 0,
		numeric ticketId = 0,
		numeric clientId = 0,
		string startDate = "",
		string endDate = ""
	) {
		var sql = "SELECT te.id, te.ticket_id, te.user_id, te.entry_date,
						  te.hours_worked, te.notes, te.created_at,
						  t.title AS ticket_title, t.contract_id,
						  c.name AS contract_name, c.hourly_rate,
						  cl.name AS client_name, cl.id AS client_id,
						  CONCAT( u.first_name, ' ', u.last_name ) AS user_name
				   FROM time_entries te
				   JOIN tickets t ON te.ticket_id = t.id
				   JOIN contracts c ON t.contract_id = c.id
				   JOIN clients cl ON c.client_id = cl.id
				   JOIN users u ON te.user_id = u.id
				   WHERE 1=1";
		var params = {};

		if ( arguments.contractId > 0 ) {
			sql &= " AND t.contract_id = :contractId";
			params.contractId = { value: arguments.contractId, cfsqltype: "cf_sql_integer" };
		}

		if ( arguments.ticketId > 0 ) {
			sql &= " AND te.ticket_id = :ticketId";
			params.ticketId = { value: arguments.ticketId, cfsqltype: "cf_sql_integer" };
		}

		if ( arguments.clientId > 0 ) {
			sql &= " AND cl.id = :clientId";
			params.clientId = { value: arguments.clientId, cfsqltype: "cf_sql_integer" };
		}

		if ( len( trim( arguments.startDate ) ) ) {
			sql &= " AND te.entry_date >= :startDate";
			params.startDate = { value: arguments.startDate, cfsqltype: "cf_sql_date" };
		}

		if ( len( trim( arguments.endDate ) ) ) {
			sql &= " AND te.entry_date <= :endDate";
			params.endDate = { value: arguments.endDate, cfsqltype: "cf_sql_date" };
		}

		sql &= " ORDER BY te.entry_date DESC, te.created_at DESC";

		return queryExecute( sql, params );
	}

	/**
	 * List time entries for a specific ticket
	 *
	 * @ticketId The ticket ID
	 *
	 * @return query
	 */
	function listByTicket( required numeric ticketId ) {
		return queryExecute(
			"SELECT te.id, te.ticket_id, te.user_id, te.entry_date,
					te.hours_worked, te.notes, te.created_at,
					t.contract_id,
					c.name AS contract_name, c.hourly_rate,
					CONCAT( u.first_name, ' ', u.last_name ) AS user_name
			 FROM time_entries te
			 JOIN tickets t ON te.ticket_id = t.id
			 JOIN contracts c ON t.contract_id = c.id
			 JOIN users u ON te.user_id = u.id
			 WHERE te.ticket_id = :ticketId
			 ORDER BY te.entry_date DESC",
			{ ticketId: { value: arguments.ticketId, cfsqltype: "cf_sql_integer" } }
		);
	}

	/**
	 * List time entries for a specific contract
	 *
	 * @contractId The contract ID
	 *
	 * @return query
	 */
	function listByContract( required numeric contractId ) {
		return queryExecute(
			"SELECT te.id, te.ticket_id, te.user_id, te.entry_date,
					te.hours_worked, te.notes, te.created_at,
					t.contract_id,
					t.title AS ticket_title,
					CONCAT( u.first_name, ' ', u.last_name ) AS user_name
			 FROM time_entries te
			 JOIN tickets t ON te.ticket_id = t.id
			 JOIN users u ON te.user_id = u.id
			 WHERE t.contract_id = :contractId
			 ORDER BY te.entry_date DESC",
			{ contractId: { value: arguments.contractId, cfsqltype: "cf_sql_integer" } }
		);
	}

	/**
	 * Get a single time entry by ID with full joins
	 *
	 * @id The time entry ID
	 *
	 * @return query
	 */
	function get( required numeric id ) {
		return queryExecute(
			"SELECT te.id, te.ticket_id, te.user_id, te.entry_date,
					te.hours_worked, te.notes, te.created_at, te.updated_at,
					t.title AS ticket_title, t.contract_id,
					c.name AS contract_name, c.hourly_rate,
					cl.name AS client_name, cl.id AS client_id,
					CONCAT( u.first_name, ' ', u.last_name ) AS user_name
			 FROM time_entries te
			 JOIN tickets t ON te.ticket_id = t.id
			 JOIN contracts c ON t.contract_id = c.id
			 JOIN clients cl ON c.client_id = cl.id
			 JOIN users u ON te.user_id = u.id
			 WHERE te.id = :id",
			{ id: { value: arguments.id, cfsqltype: "cf_sql_integer" } }
		);
	}

	/**
	 * Get uninvoiced time entries, optionally filtered by client or contract.
	 * Used by invoice creation to find billable entries.
	 *
	 * @clientId   Optional client ID filter
	 * @contractId Optional contract ID filter
	 * @startDate  Optional start date filter
	 * @endDate    Optional end date filter
	 *
	 * @return query
	 */
	function getUninvoiced(
		numeric clientId = 0,
		numeric contractId = 0,
		string startDate = "",
		string endDate = ""
	) {
		var sql = "SELECT te.id, te.ticket_id, te.user_id, te.entry_date,
						  te.hours_worked, te.notes,
						  t.title AS ticket_title, t.contract_id,
						  c.name AS contract_name, c.hourly_rate,
						  cl.name AS client_name, cl.id AS client_id
				   FROM time_entries te
				   JOIN tickets t ON te.ticket_id = t.id
				   JOIN contracts c ON t.contract_id = c.id
				   JOIN clients cl ON c.client_id = cl.id
				   LEFT JOIN invoice_line_items ili ON te.id = ili.time_entry_id
				   WHERE ili.id IS NULL";
		var params = {};

		if ( arguments.clientId > 0 ) {
			sql &= " AND cl.id = :clientId";
			params.clientId = { value: arguments.clientId, cfsqltype: "cf_sql_integer" };
		}

		if ( arguments.contractId > 0 ) {
			sql &= " AND t.contract_id = :contractId";
			params.contractId = { value: arguments.contractId, cfsqltype: "cf_sql_integer" };
		}

		if ( len( trim( arguments.startDate ) ) ) {
			sql &= " AND te.entry_date >= :startDate";
			params.startDate = { value: arguments.startDate, cfsqltype: "cf_sql_date" };
		}

		if ( len( trim( arguments.endDate ) ) ) {
			sql &= " AND te.entry_date <= :endDate";
			params.endDate = { value: arguments.endDate, cfsqltype: "cf_sql_date" };
		}

		sql &= " ORDER BY te.entry_date ASC, cl.name ASC";

		return queryExecute( sql, params );
	}

	/**
	 * Create a new time entry
	 *
	 * @data Struct containing ticket_id, user_id, entry_date, hours_worked, notes
	 *
	 * @return numeric The new time entry ID
	 */
	function create( required struct data ) {
		if ( !val( arguments.data.hours_worked ?: 0 ) ) {
			throw( type = "validation", message = "Hours worked must be greater than zero." );
		}
		if ( !val( arguments.data.ticket_id ?: 0 ) ) {
			throw( type = "validation", message = "A ticket is required." );
		}

		queryExecute(
			"INSERT INTO time_entries ( ticket_id, user_id, entry_date, hours_worked, notes )
			 VALUES ( :ticket_id, :user_id, :entry_date, :hours_worked, :notes )",
			{
				ticket_id: { value: arguments.data.ticket_id, cfsqltype: "cf_sql_integer" },
				user_id: { value: arguments.data.user_id, cfsqltype: "cf_sql_integer" },
				entry_date: { value: arguments.data.entry_date, cfsqltype: "cf_sql_date" },
				hours_worked: { value: arguments.data.hours_worked, cfsqltype: "cf_sql_decimal" },
				notes: { value: trim( arguments.data.notes ?: "" ), cfsqltype: "cf_sql_varchar", null: !len( trim( arguments.data.notes ?: "" ) ) }
			},
			{ result: "local.insertResult" }
		);

		return local.insertResult.generatedKey;
	}

	/**
	 * Update an existing time entry
	 *
	 * @id   The time entry ID
	 * @data Struct containing ticket_id, entry_date, hours_worked, notes
	 */
	function update( required numeric id, required struct data ) {
		if ( !val( arguments.data.hours_worked ?: 0 ) ) {
			throw( type = "validation", message = "Hours worked must be greater than zero." );
		}

		queryExecute(
			"UPDATE time_entries
			 SET ticket_id = :ticket_id,
				 entry_date = :entry_date, hours_worked = :hours_worked, notes = :notes
			 WHERE id = :id",
			{
				id: { value: arguments.id, cfsqltype: "cf_sql_integer" },
				ticket_id: { value: arguments.data.ticket_id, cfsqltype: "cf_sql_integer" },
				entry_date: { value: arguments.data.entry_date, cfsqltype: "cf_sql_date" },
				hours_worked: { value: arguments.data.hours_worked, cfsqltype: "cf_sql_decimal" },
				notes: { value: trim( arguments.data.notes ?: "" ), cfsqltype: "cf_sql_varchar", null: !len( trim( arguments.data.notes ?: "" ) ) }
			}
		);
	}

	/**
	 * Delete a time entry. Fails if linked to an invoice line item.
	 *
	 * @id The time entry ID
	 */
	function delete( required numeric id ) {
		var linked = queryExecute(
			"SELECT COUNT( id ) AS cnt FROM invoice_line_items WHERE time_entry_id = :id",
			{ id: { value: arguments.id, cfsqltype: "cf_sql_integer" } }
		);

		if ( linked.cnt > 0 ) {
			throw( type = "validation", message = "Cannot delete a time entry that has been invoiced." );
		}

		queryExecute(
			"DELETE FROM time_entries WHERE id = :id",
			{ id: { value: arguments.id, cfsqltype: "cf_sql_integer" } }
		);
	}

}
