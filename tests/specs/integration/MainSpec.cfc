/**
 * Main Handler Integration Tests
 */
component extends="coldbox.system.testing.BaseTestCase" appMapping="/app" {

	function beforeAll() {
		super.beforeAll();
	}

	function afterAll() {
		super.afterAll();
	}

	function run() {
		describe( "Main Handler", function() {
			beforeEach( function( currentSpec ) {
				setup();
				// Simulate authenticated session
				session.user = {
					id: 1,
					email: "admin@hourstrack.local",
					first_name: "Admin",
					last_name: "User",
					role: "admin"
				};
			} );

			it( "can render the dashboard", function() {
				var event = this.get( "main.index" );
				var prc = event.getPrivateCollection();
				expect( prc ).toHaveKey( "activeContracts" );
				expect( prc ).toHaveKey( "hoursThisMonth" );
				expect( prc ).toHaveKey( "outstandingBalance" );
				expect( prc ).toHaveKey( "monthlyRevenue" );
				expect( prc ).toHaveKey( "recentEntries" );
				expect( prc ).toHaveKey( "outstandingInvoices" );
			} );

			it( "redirects unauthenticated users to login", function() {
				structDelete( session, "user" );
				var event = execute( event = "main.index" );
				expect( event.getValue( "relocate_event", "" ) ).toBe( "auth.loginForm" );
			} );
		} );
	}

}
