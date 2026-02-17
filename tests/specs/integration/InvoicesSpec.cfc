/**
 * Invoices Handler Integration Tests
 */
component extends="coldbox.system.testing.BaseTestCase" appMapping="/app" {

	function beforeAll() {
		super.beforeAll();
	}

	function afterAll() {
		super.afterAll();
	}

	function run() {
		describe( "Invoices Handler", function() {
			beforeEach( function( currentSpec ) {
				setup();
				session.user = {
					id: 1,
					email: "admin@hourstrack.local",
					first_name: "Admin",
					last_name: "User",
					role: "admin"
				};
			} );

			it( "can list invoices", function() {
				var event = this.get( "invoices.index" );
				var prc = event.getPrivateCollection();
				expect( prc ).toHaveKey( "invoices" );
				expect( prc.invoices ).toBeQuery();
			} );

			it( "can filter invoices by status", function() {
				var event = this.get( "invoices.index", { status: "paid" } );
				var prc = event.getPrivateCollection();
				expect( prc ).toHaveKey( "invoices" );
			} );

			it( "can render the new invoice form", function() {
				var event = this.get( "invoices.new" );
				var prc = event.getPrivateCollection();
				expect( prc ).toHaveKey( "clients" );
				expect( prc ).toHaveKey( "uninvoiced" );
			} );

			it( "can show an invoice", function() {
				var event = this.get( "invoices.show", { id: 1 } );
				var prc = event.getPrivateCollection();
				expect( prc ).toHaveKey( "invoice" );
				expect( prc ).toHaveKey( "lineItems" );
				expect( prc ).toHaveKey( "payments" );
			} );

			it( "redirects show for non-existent invoice", function() {
				var event = this.get( "invoices.show", { id: 99999 } );
				expect( event.getValue( "relocate_event", "" ) ).toBe( "invoices" );
			} );
		} );
	}

}
