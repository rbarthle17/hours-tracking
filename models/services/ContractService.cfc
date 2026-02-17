/**
 * ContractService
 *
 * CRUD operations for contract records.
 */
component singleton accessors="true" {

	/**
	 * List all contracts with client name, optionally filtered
	 *
	 * @clientId Optional client ID filter
	 * @status   Optional status filter
	 *
	 * @return query
	 */
	function list( numeric clientId = 0, string status = "" ) {
		var sql    = "SELECT c.id, c.client_id, c.name, c.hourly_rate, c.start_date, c.end_date,
						     c.status, c.created_at, c.updated_at,
						     cl.name AS client_name
					  FROM contracts c
					  JOIN clients cl ON c.client_id = cl.id
					  WHERE 1=1";
		var params = {};

		if ( arguments.clientId > 0 ) {
			sql &= " AND c.client_id = :clientId";
			params.clientId = { value: arguments.clientId, cfsqltype: "cf_sql_integer" };
		}

		if ( len( trim( arguments.status ) ) ) {
			sql &= " AND c.status = :status";
			params.status = { value: arguments.status, cfsqltype: "cf_sql_varchar" };
		}

		sql &= " ORDER BY c.status ASC, c.start_date DESC";

		return queryExecute( sql, params );
	}

	/**
	 * List contracts for a specific client
	 *
	 * @clientId The client ID
	 *
	 * @return query
	 */
	function listByClient( required numeric clientId ) {
		return queryExecute(
			"SELECT id, client_id, name, hourly_rate, start_date, end_date, status, created_at
			 FROM contracts
			 WHERE client_id = :clientId
			 ORDER BY status ASC, start_date DESC",
			{ clientId: { value: arguments.clientId, cfsqltype: "cf_sql_integer" } }
		);
	}

	/**
	 * Get only active contracts (for dropdowns)
	 *
	 * @return query
	 */
	function getActiveContracts() {
		return queryExecute(
			"SELECT c.id, c.name, c.hourly_rate, c.client_id, cl.name AS client_name
			 FROM contracts c
			 JOIN clients cl ON c.client_id = cl.id
			 WHERE c.status = 'active'
			 ORDER BY cl.name ASC, c.name ASC"
		);
	}

	/**
	 * Get a single contract by ID with client name
	 *
	 * @id The contract ID
	 *
	 * @return query
	 */
	function get( required numeric id ) {
		return queryExecute(
			"SELECT c.id, c.client_id, c.name, c.hourly_rate, c.start_date, c.end_date,
					c.status, c.created_at, c.updated_at,
					cl.name AS client_name
			 FROM contracts c
			 JOIN clients cl ON c.client_id = cl.id
			 WHERE c.id = :id",
			{ id: { value: arguments.id, cfsqltype: "cf_sql_integer" } }
		);
	}

	/**
	 * Create a new contract
	 *
	 * @data Struct containing client_id, name, hourly_rate, start_date, end_date, status
	 *
	 * @return numeric The new contract ID
	 */
	function create( required struct data ) {
		if ( !len( trim( arguments.data.name ?: "" ) ) ) {
			throw( type = "validation", message = "Contract name is required." );
		}
		if ( !val( arguments.data.hourly_rate ?: 0 ) ) {
			throw( type = "validation", message = "Hourly rate must be greater than zero." );
		}

		queryExecute(
			"INSERT INTO contracts ( client_id, name, hourly_rate, start_date, end_date, status )
			 VALUES ( :client_id, :name, :hourly_rate, :start_date, :end_date, :status )",
			{
				client_id: { value: arguments.data.client_id, cfsqltype: "cf_sql_integer" },
				name: { value: trim( arguments.data.name ), cfsqltype: "cf_sql_varchar" },
				hourly_rate: { value: arguments.data.hourly_rate, cfsqltype: "cf_sql_decimal" },
				start_date: { value: arguments.data.start_date, cfsqltype: "cf_sql_date" },
				end_date: { value: arguments.data.end_date ?: "", cfsqltype: "cf_sql_date", null: !len( trim( arguments.data.end_date ?: "" ) ) },
				status: { value: arguments.data.status ?: "active", cfsqltype: "cf_sql_varchar" }
			},
			{ result: "local.insertResult" }
		);

		return local.insertResult.generatedKey;
	}

	/**
	 * Update an existing contract
	 *
	 * @id   The contract ID
	 * @data Struct containing client_id, name, hourly_rate, start_date, end_date, status
	 */
	function update( required numeric id, required struct data ) {
		if ( !len( trim( arguments.data.name ?: "" ) ) ) {
			throw( type = "validation", message = "Contract name is required." );
		}

		queryExecute(
			"UPDATE contracts
			 SET client_id = :client_id, name = :name, hourly_rate = :hourly_rate,
				 start_date = :start_date, end_date = :end_date, status = :status
			 WHERE id = :id",
			{
				id: { value: arguments.id, cfsqltype: "cf_sql_integer" },
				client_id: { value: arguments.data.client_id, cfsqltype: "cf_sql_integer" },
				name: { value: trim( arguments.data.name ), cfsqltype: "cf_sql_varchar" },
				hourly_rate: { value: arguments.data.hourly_rate, cfsqltype: "cf_sql_decimal" },
				start_date: { value: arguments.data.start_date, cfsqltype: "cf_sql_date" },
				end_date: { value: arguments.data.end_date ?: "", cfsqltype: "cf_sql_date", null: !len( trim( arguments.data.end_date ?: "" ) ) },
				status: { value: arguments.data.status ?: "active", cfsqltype: "cf_sql_varchar" }
			}
		);
	}

	/**
	 * Delete a contract. Fails if time entries exist.
	 *
	 * @id The contract ID
	 */
	function delete( required numeric id ) {
		queryExecute(
			"DELETE FROM contracts WHERE id = :id",
			{ id: { value: arguments.id, cfsqltype: "cf_sql_integer" } }
		);
	}

}
