/**
 * Users Handler
 *
 * Admin-only CRUD for managing user accounts.
 */
component extends="coldbox.system.EventHandler" {

	property name="userService" inject="UserService";

	/**
	 * Pre-handler: restrict all actions to admin users
	 */
	function preHandler( event, rc, prc, action, eventArguments ) {
		if ( !isAdmin() ) {
			flash.put( "message", "You do not have permission to access that page." );
			flash.put( "messageType", "danger" );
			relocate( "/" );
		}
	}

	/**
	 * List all users
	 */
	function index( event, rc, prc ) {
		prc.users = userService.list( rc.search ?: "" );
		event.setView( "users/index" );
	}

	/**
	 * Display the new user form
	 */
	function new( event, rc, prc ) {
		event.setView( "users/new" );
	}

	/**
	 * Create a new user
	 */
	function create( event, rc, prc ) {
		try {
			userService.create( rc );
			flash.put( "message", "User created successfully." );
			relocate( "users" );
		} catch ( any e ) {
			flash.put( "message", "Error creating user: #e.message#" );
			flash.put( "messageType", "danger" );
			relocate( "users.new" );
		}
	}

	/**
	 * Display the edit user form
	 */
	function edit( event, rc, prc ) {
		prc.user = userService.get( rc.id );
		if ( !prc.user.recordCount ) {
			flash.put( "message", "User not found." );
			flash.put( "messageType", "danger" );
			relocate( "users" );
		}
		event.setView( "users/edit" );
	}

	/**
	 * Update an existing user
	 */
	function update( event, rc, prc ) {
		userService.update( rc.id, rc );

		// If a new password was provided, update it
		if ( len( trim( rc.password ?: "" ) ) ) {
			userService.updatePassword( rc.id, rc.password );
		}

		flash.put( "message", "User updated successfully." );
		relocate( "users" );
	}

	/**
	 * Delete a user
	 */
	function delete( event, rc, prc ) {
		// Prevent deleting yourself
		if ( rc.id == session.user.id ) {
			flash.put( "message", "You cannot delete your own account." );
			flash.put( "messageType", "danger" );
			relocate( "users" );
			return;
		}

		try {
			userService.delete( rc.id );
			flash.put( "message", "User deleted." );
		} catch ( database e ) {
			flash.put( "message", "Cannot delete user: they have associated time entries." );
			flash.put( "messageType", "danger" );
		}

		relocate( "users" );
	}

}
