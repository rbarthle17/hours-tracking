/**
 * ClientService
 *
 * CRUD operations for client records.
 */
component singleton accessors="true" {

	/**
	 * List all clients, optionally filtered by search term
	 *
	 * @search Optional search string to filter by name or email
	 *
	 * @return query
	 */
	function list( string search = "" ) {
		var sql    = "SELECT id, name, email, phone, address, created_at, updated_at
					  FROM clients";
		var params = {};

		if ( len( trim( arguments.search ) ) ) {
			sql &= " WHERE name LIKE :search OR email LIKE :search";
			params.search = { value: "%#trim( arguments.search )#%", cfsqltype: "cf_sql_varchar" };
		}

		sql &= " ORDER BY name ASC";

		return queryExecute( sql, params );
	}

	/**
	 * Get a single client by ID
	 *
	 * @id The client ID
	 *
	 * @return query
	 */
	function get( required numeric id ) {
		return queryExecute(
			"SELECT id, name, email, phone, address, created_at, updated_at
			 FROM clients
			 WHERE id = :id",
			{ id: { value: arguments.id, cfsqltype: "cf_sql_integer" } }
		);
	}

	/**
	 * Create a new client
	 *
	 * @data Struct containing name, email, phone, address
	 *
	 * @return numeric The new client ID
	 */
	function create( required struct data ) {
		if ( !len( trim( arguments.data.name ?: "" ) ) ) {
			throw( type = "validation", message = "Client name is required." );
		}

		queryExecute(
			"INSERT INTO clients ( name, email, phone, address )
			 VALUES ( :name, :email, :phone, :address )",
			{
				name: { value: trim( arguments.data.name ), cfsqltype: "cf_sql_varchar" },
				email: { value: trim( arguments.data.email ?: "" ), cfsqltype: "cf_sql_varchar", null: !len( trim( arguments.data.email ?: "" ) ) },
				phone: { value: trim( arguments.data.phone ?: "" ), cfsqltype: "cf_sql_varchar", null: !len( trim( arguments.data.phone ?: "" ) ) },
				address: { value: trim( arguments.data.address ?: "" ), cfsqltype: "cf_sql_varchar", null: !len( trim( arguments.data.address ?: "" ) ) }
			},
			{ result: "local.insertResult" }
		);

		return local.insertResult.generatedKey;
	}

	/**
	 * Update an existing client
	 *
	 * @id   The client ID
	 * @data Struct containing name, email, phone, address
	 */
	function update( required numeric id, required struct data ) {
		if ( !len( trim( arguments.data.name ?: "" ) ) ) {
			throw( type = "validation", message = "Client name is required." );
		}

		queryExecute(
			"UPDATE clients
			 SET name = :name, email = :email, phone = :phone, address = :address
			 WHERE id = :id",
			{
				id: { value: arguments.id, cfsqltype: "cf_sql_integer" },
				name: { value: trim( arguments.data.name ), cfsqltype: "cf_sql_varchar" },
				email: { value: trim( arguments.data.email ?: "" ), cfsqltype: "cf_sql_varchar", null: !len( trim( arguments.data.email ?: "" ) ) },
				phone: { value: trim( arguments.data.phone ?: "" ), cfsqltype: "cf_sql_varchar", null: !len( trim( arguments.data.phone ?: "" ) ) },
				address: { value: trim( arguments.data.address ?: "" ), cfsqltype: "cf_sql_varchar", null: !len( trim( arguments.data.address ?: "" ) ) }
			}
		);
	}

	/**
	 * Delete a client. Fails if the client has associated contracts.
	 *
	 * @id The client ID
	 */
	function delete( required numeric id ) {
		queryExecute(
			"DELETE FROM clients WHERE id = :id",
			{ id: { value: arguments.id, cfsqltype: "cf_sql_integer" } }
		);
	}

}
