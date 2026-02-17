/**
 * AuthService
 *
 * Handles authentication: login verification, password hashing, and session management.
 * Uses SHA-512 with a per-user salt for password security.
 */
component singleton accessors="true" {

	property name="userService" inject="UserService";

	/**
	 * Authenticate a user by email and password.
	 * Returns a user struct on success, throws on failure.
	 *
	 * @email    The user's email address
	 * @password The plaintext password to verify
	 *
	 * @return struct User data (id, email, first_name, last_name, role)
	 * @throws  InvalidCredentials
	 */
	function authenticate( required string email, required string password ) {
		var userQuery = userService.getByEmail( arguments.email );

		if ( !userQuery.recordCount ) {
			throw( type = "InvalidCredentials", message = "Invalid email or password." );
		}

		if ( !userQuery.is_active ) {
			throw( type = "InvalidCredentials", message = "This account has been deactivated." );
		}

		if ( !verifyPassword( arguments.password, userQuery.password_hash, userQuery.salt ) ) {
			throw( type = "InvalidCredentials", message = "Invalid email or password." );
		}

		userService.updateLastLogin( userQuery.id );

		return {
			"id"         : userQuery.id,
			"email"      : userQuery.email,
			"first_name" : userQuery.first_name,
			"last_name"  : userQuery.last_name,
			"role"       : userQuery.role
		};
	}

	/**
	 * Generate a unique salt for password hashing
	 *
	 * @return string A UUID salt
	 */
	function generateSalt() {
		return createUUID();
	}

	/**
	 * Hash a plaintext password with the given salt using SHA-512
	 *
	 * @password The plaintext password to hash
	 * @salt     The per-user salt
	 *
	 * @return string The SHA-512 hash
	 */
	function hashPassword( required string password, required string salt ) {
		return hash( arguments.salt & arguments.password, "SHA-512" );
	}

	/**
	 * Verify a plaintext password against a stored hash and salt
	 *
	 * @password       The plaintext password
	 * @hashedPassword The stored hash
	 * @salt           The stored salt
	 *
	 * @return boolean True if the password matches
	 */
	function verifyPassword( required string password, required string hashedPassword, required string salt ) {
		return hashPassword( arguments.password, arguments.salt ) == arguments.hashedPassword;
	}

}
