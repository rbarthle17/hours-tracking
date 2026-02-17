/**
 * TicketService
 *
 * CRUD operations for ticket/task records.
 * Tickets belong to clients and survive contract renewals.
 */
component singleton accessors="true" {

	/**
	 * List all tickets with client name, optionally filtered
	 *
	 * @clientId Optional client ID filter
	 * @status   Optional status filter
	 * @priority Optional priority filter
	 *
	 * @return query
	 */
	function list( numeric clientId = 0, string status = "", string priority = "" ) {
		var sql    = "SELECT t.id, t.client_id, t.title, t.description, t.status, t.priority,
						     t.created_at, t.updated_at,
						     cl.name AS client_name
					  FROM tickets t
					  JOIN clients cl ON t.client_id = cl.id
					  WHERE 1=1";
		var params = {};

		if ( arguments.clientId > 0 ) {
			sql &= " AND t.client_id = :clientId";
			params.clientId = { value: arguments.clientId, cfsqltype: "cf_sql_integer" };
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
	 * List tickets for a specific client
	 *
	 * @clientId The client ID
	 *
	 * @return query
	 */
	function listByClient( required numeric clientId ) {
		return queryExecute(
			"SELECT id, client_id, title, status, priority, created_at
			 FROM tickets
			 WHERE client_id = :clientId
			 ORDER BY FIELD( status, 'in_progress', 'open', 'done', 'closed' ), created_at DESC",
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
			"SELECT t.id, t.title, t.client_id, cl.name AS client_name
			 FROM tickets t
			 JOIN clients cl ON t.client_id = cl.id
			 WHERE t.status IN ( 'open', 'in_progress' )
			 ORDER BY cl.name ASC, t.title ASC"
		);
	}

	/**
	 * Get a single ticket by ID with client name
	 *
	 * @id The ticket ID
	 *
	 * @return query
	 */
	function get( required numeric id ) {
		return queryExecute(
			"SELECT t.id, t.client_id, t.title, t.description, t.status, t.priority,
					t.created_at, t.updated_at,
					cl.name AS client_name
			 FROM tickets t
			 JOIN clients cl ON t.client_id = cl.id
			 WHERE t.id = :id",
			{ id: { value: arguments.id, cfsqltype: "cf_sql_integer" } }
		);
	}

	/**
	 * Create a new ticket
	 *
	 * @data Struct containing client_id, title, description, status, priority
	 *
	 * @return numeric The new ticket ID
	 */
	function create( required struct data ) {
		if ( !len( trim( arguments.data.title ?: "" ) ) ) {
			throw( type = "validation", message = "Ticket title is required." );
		}

		queryExecute(
			"INSERT INTO tickets ( client_id, title, description, status, priority )
			 VALUES ( :client_id, :title, :description, :status, :priority )",
			{
				client_id: { value: arguments.data.client_id, cfsqltype: "cf_sql_integer" },
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
	 * @data Struct containing client_id, title, description, status, priority
	 */
	function update( required numeric id, required struct data ) {
		if ( !len( trim( arguments.data.title ?: "" ) ) ) {
			throw( type = "validation", message = "Ticket title is required." );
		}

		queryExecute(
			"UPDATE tickets
			 SET client_id = :client_id, title = :title, description = :description,
				 status = :status, priority = :priority
			 WHERE id = :id",
			{
				id: { value: arguments.id, cfsqltype: "cf_sql_integer" },
				client_id: { value: arguments.data.client_id, cfsqltype: "cf_sql_integer" },
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
