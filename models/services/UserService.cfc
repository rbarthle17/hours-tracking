/**
 * UserService
 *
 * CRUD operations for user accounts.
 */
component singleton accessors="true" {

	property name="authService" inject="provider:AuthService";

	/**
	 * List all users, optionally filtered by search term
	 *
	 * @search Optional search string to filter by name or email
	 *
	 * @return query
	 */
	function list( string search = "" ) {
		var sql    = "SELECT id, email, first_name, last_name, role, is_active, last_login_at, created_at
					  FROM users";
		var params = {};

		if ( len( trim( arguments.search ) ) ) {
			sql &= " WHERE first_name LIKE :search
					  OR last_name LIKE :search
					  OR email LIKE :search";
			params.search = { value: "%#trim( arguments.search )#%", cfsqltype: "cf_sql_varchar" };
		}

		sql &= " ORDER BY last_name ASC, first_name ASC";

		return queryExecute( sql, params );
	}

	/**
	 * Get a single user by ID
	 *
	 * @id The user ID
	 *
	 * @return query
	 */
	function get( required numeric id ) {
		return queryExecute(
			"SELECT id, email, first_name, last_name, role, is_active, last_login_at, created_at, updated_at
			 FROM users
			 WHERE id = :id",
			{ id: { value: arguments.id, cfsqltype: "cf_sql_integer" } }
		);
	}

	/**
	 * Get a single user by email (includes password_hash and salt for authentication)
	 *
	 * @email The user's email address
	 *
	 * @return query
	 */
	function getByEmail( required string email ) {
		return queryExecute(
			"SELECT id, email, password_hash, salt, first_name, last_name, role, is_active
			 FROM users
			 WHERE email = :email",
			{ email: { value: arguments.email, cfsqltype: "cf_sql_varchar" } }
		);
	}

	/**
	 * Create a new user
	 *
	 * @data Struct containing email, password, first_name, last_name, role
	 *
	 * @return numeric The new user ID
	 */
	function create( required struct data ) {
		var salt       = authService.generateSalt();
		var hashedPass = authService.hashPassword( arguments.data.password, salt );

		queryExecute(
			"INSERT INTO users ( email, password_hash, salt, first_name, last_name, role, is_active )
			 VALUES ( :email, :password_hash, :salt, :first_name, :last_name, :role, :is_active )",
			{
				email: { value: trim( arguments.data.email ), cfsqltype: "cf_sql_varchar" },
				password_hash: { value: hashedPass, cfsqltype: "cf_sql_varchar" },
				salt: { value: salt, cfsqltype: "cf_sql_varchar" },
				first_name: { value: trim( arguments.data.first_name ), cfsqltype: "cf_sql_varchar" },
				last_name: { value: trim( arguments.data.last_name ), cfsqltype: "cf_sql_varchar" },
				role: { value: arguments.data.role ?: "contractor", cfsqltype: "cf_sql_varchar" },
				is_active: { value: arguments.data.is_active ?: true, cfsqltype: "cf_sql_bit" }
			},
			{ result: "local.insertResult" }
		);

		return local.insertResult.generatedKey;
	}

	/**
	 * Update an existing user (does not change password)
	 *
	 * @id   The user ID
	 * @data Struct containing email, first_name, last_name, role, is_active
	 */
	function update( required numeric id, required struct data ) {
		queryExecute(
			"UPDATE users
			 SET email = :email,
				 first_name = :first_name,
				 last_name = :last_name,
				 role = :role,
				 is_active = :is_active
			 WHERE id = :id",
			{
				id: { value: arguments.id, cfsqltype: "cf_sql_integer" },
				email: { value: trim( arguments.data.email ), cfsqltype: "cf_sql_varchar" },
				first_name: { value: trim( arguments.data.first_name ), cfsqltype: "cf_sql_varchar" },
				last_name: { value: trim( arguments.data.last_name ), cfsqltype: "cf_sql_varchar" },
				role: { value: arguments.data.role, cfsqltype: "cf_sql_varchar" },
				is_active: { value: arguments.data.is_active ?: true, cfsqltype: "cf_sql_bit" }
			}
		);
	}

	/**
	 * Update a user's password
	 *
	 * @id       The user ID
	 * @password The new plaintext password
	 */
	function updatePassword( required numeric id, required string password ) {
		var salt       = authService.generateSalt();
		var hashedPass = authService.hashPassword( arguments.password, salt );

		queryExecute(
			"UPDATE users
			 SET password_hash = :password_hash, salt = :salt
			 WHERE id = :id",
			{
				id: { value: arguments.id, cfsqltype: "cf_sql_integer" },
				password_hash: { value: hashedPass, cfsqltype: "cf_sql_varchar" },
				salt: { value: salt, cfsqltype: "cf_sql_varchar" }
			}
		);
	}

	/**
	 * Update the last_login_at timestamp for a user
	 *
	 * @id The user ID
	 */
	function updateLastLogin( required numeric id ) {
		queryExecute(
			"UPDATE users SET last_login_at = NOW() WHERE id = :id",
			{ id: { value: arguments.id, cfsqltype: "cf_sql_integer" } }
		);
	}

	/**
	 * Delete a user
	 *
	 * @id The user ID
	 */
	function delete( required numeric id ) {
		queryExecute(
			"DELETE FROM users WHERE id = :id",
			{ id: { value: arguments.id, cfsqltype: "cf_sql_integer" } }
		);
	}

}
