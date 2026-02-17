/**
 * Invoices Handler
 *
 * CRUD and workflow operations for invoice management.
 */
component extends="coldbox.system.EventHandler" {

	property name="invoiceService" inject="InvoiceService";
	property name="clientService" inject="ClientService";
	property name="timeEntryService" inject="TimeEntryService";

	/**
	 * List all invoices with filters
	 */
	function index( event, rc, prc ) {
		prc.invoices = invoiceService.list(
			clientId = val( rc.client_id ?: 0 ),
			status = rc.status ?: ""
		);
		prc.clients = clientService.list();
		event.setView( "invoices/index" );
	}

	/**
	 * Display the new invoice form — select client then see uninvoiced entries
	 */
	function new( event, rc, prc ) {
		prc.clients = clientService.list();
		prc.uninvoiced = timeEntryService.getUninvoiced(
			clientId = val( rc.client_id ?: 0 )
		);
		event.setView( "invoices/new" );
	}

	/**
	 * Create an invoice from selected time entries
	 */
	function create( event, rc, prc ) {
		try {
			var timeEntryIds = listToArray( rc.time_entry_ids ?: "" );
			var newId = invoiceService.createFromTimeEntries(
				clientId = rc.client_id,
				timeEntryIds = timeEntryIds,
				invoiceDate = rc.invoice_date,
				dueDate = rc.due_date,
				notes = rc.notes ?: ""
			);
			flash.put( "message", "Invoice created successfully." );
			relocate( "invoices.show", { id: newId } );
		} catch ( validation e ) {
			flash.put( "message", e.message );
			flash.put( "messageType", "danger" );
			relocate( "invoices.new" );
		}
	}

	/**
	 * Display a single invoice with line items and payments
	 */
	function show( event, rc, prc ) {
		prc.invoice = invoiceService.get( rc.id );
		if ( !prc.invoice.recordCount ) {
			flash.put( "message", "Invoice not found." );
			flash.put( "messageType", "danger" );
			relocate( "invoices" );
		}
		prc.lineItems = invoiceService.getLineItems( rc.id );
		prc.payments = queryExecute(
			"SELECT id, payment_date, amount, method, reference_number, notes, created_at
			 FROM payments
			 WHERE invoice_id = :invoiceId
			 ORDER BY payment_date DESC",
			{ invoiceId: { value: rc.id, cfsqltype: "cf_sql_integer" } }
		);
		event.setView( "invoices/show" );
	}

	/**
	 * Display the edit invoice form (draft only)
	 */
	function edit( event, rc, prc ) {
		prc.invoice = invoiceService.get( rc.id );
		if ( !prc.invoice.recordCount ) {
			flash.put( "message", "Invoice not found." );
			flash.put( "messageType", "danger" );
			relocate( "invoices" );
		}
		if ( prc.invoice.status != "draft" ) {
			flash.put( "message", "Only draft invoices can be edited." );
			flash.put( "messageType", "danger" );
			relocate( "invoices.show", { id: rc.id } );
		}
		event.setView( "invoices/edit" );
	}

	/**
	 * Update an invoice (draft only)
	 */
	function update( event, rc, prc ) {
		try {
			invoiceService.update( rc.id, rc );
			flash.put( "message", "Invoice updated successfully." );
			relocate( "invoices.show", { id: rc.id } );
		} catch ( validation e ) {
			flash.put( "message", e.message );
			flash.put( "messageType", "danger" );
			relocate( "invoices.edit", { id: rc.id } );
		}
	}

	/**
	 * Mark an invoice as sent
	 */
	function send( event, rc, prc ) {
		invoiceService.updateStatus( rc.id, "sent" );
		flash.put( "message", "Invoice marked as sent." );
		relocate( "invoices.show", { id: rc.id } );
	}

	/**
	 * Delete a draft invoice
	 */
	function delete( event, rc, prc ) {
		try {
			invoiceService.delete( rc.id );
			flash.put( "message", "Invoice deleted." );
		} catch ( validation e ) {
			flash.put( "message", e.message );
			flash.put( "messageType", "danger" );
		}
		relocate( "invoices" );
	}

}
