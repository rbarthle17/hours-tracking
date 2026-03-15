/**
 * TicketService
 *
 * CRUD operations for ticket/task records.
 * Tickets belong to contracts. Client is derived via the contract.
 */
component singleton accessors="true" {

	/**
	 * List all tickets with contract and client names, optionally filtered
	 *
	 * @clientId   Optional client ID filter (derived through contract)
	 * @contractId Optional contract ID filter
	 * @status     Optional status filter
	 * @priority   Optional priority filter
	 *
	 * @return query
	 */
	function list( numeric clientId = 0, numeric contractId = 0, string status = "", string priority = "" ) {
		var sql    = "SELECT t.id, t.contract_id, t.title, t.description, t.status, t.priority,
						     t.created_at, t.updated_at,
						     co.name AS contract_name, co.hourly_rate,
						     cl.id AS client_id, cl.name AS client_name
					  FROM tickets t
					  JOIN contracts co ON t.contract_id = co.id
					  JOIN clients cl ON co.client_id = cl.id
					  WHERE 1=1";
		var params = {};

		if ( arguments.clientId > 0 ) {
			sql &= " AND co.client_id = :clientId";
			params.clientId = { value: arguments.clientId, cfsqltype: "cf_sql_integer" };
		}

		if ( arguments.contractId > 0 ) {
			sql &= " AND t.contract_id = :contractId";
			params.contractId = { value: arguments.contractId, cfsqltype: "cf_sql_integer" };
		}

		if ( len( trim( arguments.status ) ) ) {
			sql &= " AND t.status = :status";
			params.status = { value: arguments.status, cfsqltype: "cf_sql_varchar" };
		}

		if ( len( trim( arguments.priority ) ) ) {
			sql &= " AND t.priority = :priority";
			params.priority = { value: arguments.priority, cfsqltype: "cf_sql_varchar" };
		}

		sql &= " ORDER BY FIELD( t.status, 'in_progress', 'open', 'done', 'closed' ), t.created_at DESC";

		return queryExecute( sql, params );
	}

	/**
	 * List tickets for a specific client (derived through contract)
	 *
	 * @clientId The client ID
	 *
	 * @return query
	 */
	function listByClient( required numeric clientId ) {
		return queryExecute(
			"SELECT t.id, t.contract_id, t.title, t.status, t.priority, t.created_at,
					co.name AS contract_name
			 FROM tickets t
			 JOIN contracts co ON t.contract_id = co.id
			 WHERE co.client_id = :clientId
			 ORDER BY FIELD( t.status, 'in_progress', 'open', 'done', 'closed' ), t.created_at DESC",
			{ clientId: { value: arguments.clientId, cfsqltype: "cf_sql_integer" } }
		);
	}

	/**
	 * Get open/in-progress tickets for time entry dropdowns
	 *
	 * @return query
	 */
	function getActiveTickets() {
		return queryExecute(
			"SELECT t.id, t.title, t.contract_id,
					co.name AS contract_name,
					cl.id AS client_id, cl.name AS client_name
			 FROM tickets t
			 JOIN contracts co ON t.contract_id = co.id
			 JOIN clients cl ON co.client_id = cl.id
			 WHERE t.status IN ( 'open', 'in_progress' )
			 ORDER BY cl.name ASC, t.title ASC"
		);
	}

	/**
	 * Get a single ticket by ID with contract and client names
	 *
	 * @id The ticket ID
	 *
	 * @return query
	 */
	function get( required numeric id ) {
		return queryExecute(
			"SELECT t.id, t.contract_id, t.title, t.description, t.status, t.priority,
					t.created_at, t.updated_at,
					co.name AS contract_name, co.hourly_rate,
					cl.id AS client_id, cl.name AS client_name
			 FROM tickets t
			 JOIN contracts co ON t.contract_id = co.id
			 JOIN clients cl ON co.client_id = cl.id
			 WHERE t.id = :id",
			{ id: { value: arguments.id, cfsqltype: "cf_sql_integer" } }
		);
	}

	/**
	 * Create a new ticket
	 *
	 * @data Struct containing contract_id, title, description, status, priority
	 *
	 * @return numeric The new ticket ID
	 */
	function create( required struct data ) {
		if ( !len( trim( arguments.data.title ?: "" ) ) ) {
			throw( type = "validation", message = "Ticket title is required." );
		}

		queryExecute(
			"INSERT INTO tickets ( contract_id, title, description, status, priority )
			 VALUES ( :contract_id, :title, :description, :status, :priority )",
			{
				contract_id: { value: arguments.data.contract_id, cfsqltype: "cf_sql_integer" },
				title: { value: trim( arguments.data.title ), cfsqltype: "cf_sql_varchar" },
				description: { value: trim( arguments.data.description ?: "" ), cfsqltype: "cf_sql_varchar", null: !len( trim( arguments.data.description ?: "" ) ) },
				status: { value: arguments.data.status ?: "open", cfsqltype: "cf_sql_varchar" },
				priority: { value: arguments.data.priority ?: "medium", cfsqltype: "cf_sql_varchar" }
			},
			{ result: "local.insertResult" }
		);

		return local.insertResult.generatedKey;
	}

	/**
	 * Update an existing ticket
	 *
	 * @id   The ticket ID
	 * @data Struct containing contract_id, title, description, status, priority
	 */
	function update( required numeric id, required struct data ) {
		if ( !len( trim( arguments.data.title ?: "" ) ) ) {
			throw( type = "validation", message = "Ticket title is required." );
		}

		queryExecute(
			"UPDATE tickets
			 SET contract_id = :contract_id, title = :title, description = :description,
				 status = :status, priority = :priority
			 WHERE id = :id",
			{
				id: { value: arguments.id, cfsqltype: "cf_sql_integer" },
				contract_id: { value: arguments.data.contract_id, cfsqltype: "cf_sql_integer" },
				title: { value: trim( arguments.data.title ), cfsqltype: "cf_sql_varchar" },
				description: { value: trim( arguments.data.description ?: "" ), cfsqltype: "cf_sql_varchar", null: !len( trim( arguments.data.description ?: "" ) ) },
				status: { value: arguments.data.status ?: "open", cfsqltype: "cf_sql_varchar" },
				priority: { value: arguments.data.priority ?: "medium", cfsqltype: "cf_sql_varchar" }
			}
		);
	}

	/**
	 * Delete a ticket. Fails if time entries exist.
	 *
	 * @id The ticket ID
	 */
	function delete( required numeric id ) {
		queryExecute(
			"DELETE FROM tickets WHERE id = :id",
			{ id: { value: arguments.id, cfsqltype: "cf_sql_integer" } }
		);
	}

}
