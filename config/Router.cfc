/**
 * Application URL Router
 *
 * https://coldbox.ortusbooks.com/the-basics/routing
 */
component {

	function configure() {

		// Health check
		route( "/healthcheck", function( event, rc, prc ) {
			return "Ok!";
		} );

		// Authentication routes
		route( "/login" ).to( "Auth.loginForm" );
		route( "/auth/login" ).withAction( { POST: "login", GET: "loginForm" } ).toHandler( "Auth" );
		route( "/auth/logout" ).to( "Auth.logout" );

		// Resourceful routes
		resources( resource = "users", parameterName = "id" );
		resources( resource = "clients", parameterName = "id" );
		resources( resource = "contracts", parameterName = "id" );
		resources( resource = "tickets", parameterName = "id" );
		resources( resource = "timeentries", handler = "TimeEntries", parameterName = "id" );
		// Invoice custom actions (before resources to take precedence)
		route( "/invoices/:id/send" )
			.withAction( { POST: "send" } )
			.toHandler( "Invoices" );

		// Nested payment routes under invoices (must come before resources)
		route( "/invoices/:invoiceId/payments/new" )
			.withAction( { GET: "new" } )
			.toHandler( "Payments" );
		route( "/invoices/:invoiceId/payments" )
			.withAction( { POST: "create" } )
			.toHandler( "Payments" );
		route( "/invoices/:invoiceId/payments/:id" )
			.withAction( { DELETE: "delete" } )
			.toHandler( "Payments" );

		resources( resource = "invoices", parameterName = "id" );

		// Dashboard
		route( "/" ).to( "Main.index" );

		// Convention-based fallback
		route( ":handler/:action?" ).end();
	}

}
