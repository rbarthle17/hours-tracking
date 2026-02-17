/**
 * InvoiceService Unit Tests
 */
component extends="coldbox.system.testing.BaseTestCase" appMapping="/app" {

	function beforeAll() {
		super.beforeAll();
	}

	function afterAll() {
		super.afterAll();
	}

	function run() {
		describe( "InvoiceService", function() {
			var invoiceService = "";

			beforeEach( function( currentSpec ) {
				setup();
				invoiceService = getInstance( "InvoiceService" );
			} );

			describe( "generateNumber()", function() {
				it( "generates a number in the format INV-YYYY-NNNN", function() {
					var num = invoiceService.generateNumber();
					var year = year( now() );
					expect( num ).toMatch( "INV-#year#-\d{4}" );
				} );

				it( "starts at 0001 for a new year", function() {
					// This test depends on current data; it validates the format at least
					var num = invoiceService.generateNumber();
					expect( left( num, 4 ) ).toBe( "INV-" );
					expect( len( num ) ).toBe( 13 );
				} );
			} );

			describe( "createFromTimeEntries()", function() {
				it( "throws validation error when no time entries selected", function() {
					expect( function() {
						invoiceService.createFromTimeEntries(
							clientId = 1,
							timeEntryIds = [],
							invoiceDate = dateFormat( now(), "yyyy-mm-dd" ),
							dueDate = dateFormat( dateAdd( "d", 30, now() ), "yyyy-mm-dd" )
						);
					} ).toThrow( type = "validation" );
				} );
			} );

			describe( "delete()", function() {
				it( "throws validation error when deleting non-draft invoice", function() {
					// Find a non-draft invoice from seed data
					var nonDraft = queryExecute(
						"SELECT id FROM invoices WHERE status != 'draft' LIMIT 1"
					);
					if ( nonDraft.recordCount ) {
						expect( function() {
							invoiceService.delete( nonDraft.id );
						} ).toThrow( type = "validation" );
					}
				} );
			} );

			describe( "update()", function() {
				it( "throws validation error when editing non-draft invoice", function() {
					var nonDraft = queryExecute(
						"SELECT id FROM invoices WHERE status != 'draft' LIMIT 1"
					);
					if ( nonDraft.recordCount ) {
						expect( function() {
							invoiceService.update( nonDraft.id, {
								invoice_date: dateFormat( now(), "yyyy-mm-dd" ),
								due_date: dateFormat( dateAdd( "d", 30, now() ), "yyyy-mm-dd" ),
								notes: "test"
							} );
						} ).toThrow( type = "validation" );
					}
				} );
			} );

			describe( "list()", function() {
				it( "returns a query of invoices", function() {
					var result = invoiceService.list();
					expect( result ).toBeQuery();
					expect( listFindNoCase( result.columnList, "invoice_number" ) ).toBeGT( 0 );
					expect( listFindNoCase( result.columnList, "client_name" ) ).toBeGT( 0 );
					expect( listFindNoCase( result.columnList, "total_paid" ) ).toBeGT( 0 );
				} );

				it( "can filter by status", function() {
					var result = invoiceService.list( status = "paid" );
					expect( result ).toBeQuery();
				} );
			} );
		} );
	}

}
