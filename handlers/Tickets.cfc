/**
 * Tickets Handler
 *
 * CRUD operations for managing ticket/task records.
 */
component extends="coldbox.system.EventHandler" {

	property name="ticketService" inject="TicketService";
	property name="clientService" inject="ClientService";
	property name="timeEntryService" inject="TimeEntryService";

	/**
	 * List all tickets
	 */
	function index( event, rc, prc ) {
		prc.tickets = ticketService.list(
			clientId = val( rc.client_id ?: 0 ),
			status   = rc.status ?: "",
			priority = rc.priority ?: ""
		);
		prc.clients = clientService.list();
		event.setView( "tickets/index" );
	}

	/**
	 * Display the new ticket form
	 */
	function new( event, rc, prc ) {
		prc.clients = clientService.list();
		event.setView( "tickets/new" );
	}

	/**
	 * Create a new ticket
	 */
	function create( event, rc, prc ) {
		try {
			var newId = ticketService.create( rc );
			flash.put( "message", "Ticket created successfully." );
			relocate( "tickets.show", { id: newId } );
		} catch ( validation e ) {
			flash.put( "message", e.message );
			flash.put( "messageType", "danger" );
			relocate( "tickets.new" );
		}
	}

	/**
	 * Display a single ticket
	 */
	function show( event, rc, prc ) {
		prc.ticket = ticketService.get( rc.id );
		if ( !prc.ticket.recordCount ) {
			flash.put( "message", "Ticket not found." );
			flash.put( "messageType", "danger" );
			relocate( "tickets" );
		}
		prc.timeEntries = timeEntryService.listByTicket( rc.id );
		event.setView( "tickets/show" );
	}

	/**
	 * Display the edit ticket form
	 */
	function edit( event, rc, prc ) {
		prc.ticket = ticketService.get( rc.id );
		if ( !prc.ticket.recordCount ) {
			flash.put( "message", "Ticket not found." );
			flash.put( "messageType", "danger" );
			relocate( "tickets" );
		}
		prc.clients = clientService.list();
		event.setView( "tickets/edit" );
	}

	/**
	 * Update an existing ticket
	 */
	function update( event, rc, prc ) {
		try {
			ticketService.update( rc.id, rc );
			flash.put( "message", "Ticket updated successfully." );
			relocate( "tickets.show", { id: rc.id } );
		} catch ( validation e ) {
			flash.put( "message", e.message );
			flash.put( "messageType", "danger" );
			relocate( "tickets.edit", { id: rc.id } );
		}
	}

	/**
	 * Delete a ticket
	 */
	function delete( event, rc, prc ) {
		try {
			ticketService.delete( rc.id );
			flash.put( "message", "Ticket deleted." );
		} catch ( database e ) {
			flash.put( "message", "Cannot delete ticket: it has associated time entries." );
			flash.put( "messageType", "danger" );
		}
		relocate( "tickets" );
	}

}
