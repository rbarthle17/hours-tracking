/**
 * Auth Handler
 *
 * Handles login form display, authentication, and logout.
 */
component extends="coldbox.system.EventHandler" {

	property name="authService" inject="AuthService";

	/**
	 * Display the login form
	 */
	function loginForm( event, rc, prc ) {
		// If already logged in, redirect to dashboard
		if ( structKeyExists( session, "user" ) ) {
			relocate( "/" );
		}
		event.setView( view = "auth/login", layout = "auth" );
	}

	/**
	 * Process login form submission
	 */
	function login( event, rc, prc ) {
		try {
			var user = authService.authenticate(
				email    = rc.email ?: "",
				password = rc.password ?: ""
			);

			session.user = user;
			flash.put( "message", "Welcome back, #user.first_name#!" );
			relocate( "/" );
		} catch ( InvalidCredentials e ) {
			flash.put( "message", e.message );
			flash.put( "messageType", "danger" );
			relocate( "auth.loginForm" );
		}
	}

	/**
	 * Log the user out and destroy their session
	 */
	function logout( event, rc, prc ) {
		structDelete( session, "user" );
		flash.put( "message", "You have been logged out." );
		relocate( "auth.loginForm" );
	}

}
