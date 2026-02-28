/**
 * Clients Handler Integration Tests
 */
component extends="coldbox.system.testing.BaseTestCase" appMapping="/app" {

	function beforeAll() {
		super.beforeAll();
	}

	function afterAll() {
		super.afterAll();
	}

	function run() {
		describe( "Clients Handler", function() {
			beforeEach( function( currentSpec ) {
				setup();
				session.user = {
					id: 1,
					email: "rob.barthle@cf-expert.com",
					first_name: "Admin",
					last_name: "User",
					role: "admin"
				};
			} );

			it( "can list clients", function() {
				var event = this.get( "clients.index" );
				var prc = event.getPrivateCollection();
				expect( prc ).toHaveKey( "clients" );
				expect( prc.clients ).toBeQuery();
			} );

			it( "can render the new client form", function() {
				var event = this.get( "clients.new" );
				expect( event.getCurrentView() ).toBe( "clients/new" );
			} );

			it( "can create a client", function() {
				var event = this.post( "clients.create", {
					name: "Test Client #createUUID()#",
					email: "test@example.com",
					phone: "555-1234",
					address: "123 Test St"
				} );
				expect( event.getValue( "relocate_event", "" ) ).toInclude( "clients" );
			} );

			it( "rejects a client without a name", function() {
				var event = this.post( "clients.create", {
					name: "",
					email: "test@example.com"
				} );
				expect( event.getValue( "relocate_event", "" ) ).toBe( "clients.new" );
			} );

			it( "can show a client", function() {
				var event = this.get( "clients.show", { id: 1 } );
				var prc = event.getPrivateCollection();
				expect( prc ).toHaveKey( "client" );
				expect( prc.client ).toBeQuery();
			} );

			it( "can render the edit form", function() {
				var event = this.get( "clients.edit", { id: 1 } );
				var prc = event.getPrivateCollection();
				expect( prc ).toHaveKey( "client" );
			} );

			it( "redirects show for non-existent client", function() {
				var event = this.get( "clients.show", { id: 99999 } );
				expect( event.getValue( "relocate_event", "" ) ).toBe( "clients" );
			} );
		} );
	}

}
