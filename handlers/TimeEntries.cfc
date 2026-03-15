/**
 * TimeEntries Handler
 *
 * CRUD operations for managing time entry records.
 */
component extends="coldbox.system.EventHandler" {

	property name="timeEntryService" inject="TimeEntryService";
	property name="ticketService" inject="TicketService";
	property name="contractService" inject="ContractService";
	property name="clientService" inject="ClientService";

	/**
	 * List all time entries with filters
	 */
	function index( event, rc, prc ) {
		prc.timeEntries = timeEntryService.list(
			contractId = val( rc.contract_id ?: 0 ),
			ticketId = val( rc.ticket_id ?: 0 ),
			clientId = val( rc.client_id ?: 0 ),
			startDate = rc.start_date ?: "",
			endDate = rc.end_date ?: ""
		);
		prc.clients = clientService.list();
		prc.contracts = contractService.getActiveContracts();
		event.setView( "timeentries/index" );
	}

	/**
	 * Display the new time entry form
	 */
	function new( event, rc, prc ) {
		prc.tickets = ticketService.getActiveTickets();
		event.setView( "timeentries/new" );
	}

	/**
	 * Create a new time entry
	 */
	function create( event, rc, prc ) {
		try {
			rc.user_id = prc.currentUser.id;
			var newId = timeEntryService.create( rc );
			flash.put( "message", "Time entry logged successfully." );
			relocate( "timeentries/#newId#" );
		} catch ( validation e ) {
			flash.put( "message", e.message );
			flash.put( "messageType", "danger" );
			relocate( "timeentries.new" );
		}
	}

	/**
	 * Display a single time entry
	 */
	function show( event, rc, prc ) {
		prc.timeEntry = timeEntryService.get( val( rc.id ) );
		if ( !prc.timeEntry.recordCount ) {
			flash.put( "message", "Time entry not found." );
			flash.put( "messageType", "danger" );
			relocate( "timeentries" );
		}
		event.setView( "timeentries/show" );
	}

	/**
	 * Display the edit time entry form
	 */
	function edit( event, rc, prc ) {
		prc.timeEntry = timeEntryService.get( val( rc.id ) );
		if ( !prc.timeEntry.recordCount ) {
			flash.put( "message", "Time entry not found." );
			flash.put( "messageType", "danger" );
			relocate( "timeentries" );
		}
		prc.tickets = ticketService.getActiveTickets();
		event.setView( "timeentries/edit" );
	}

	/**
	 * Update an existing time entry
	 */
	function update( event, rc, prc ) {
		try {
			timeEntryService.update( val( rc.id ), rc );
			flash.put( "message", "Time entry updated successfully." );
			relocate( "timeentries/#rc.id#" );
		} catch ( validation e ) {
			flash.put( "message", e.message );
			flash.put( "messageType", "danger" );
			relocate( "timeentries/#rc.id#/edit" );
		}
	}

	/**
	 * Delete a time entry
	 */
	function delete( event, rc, prc ) {
		try {
			timeEntryService.delete( val( rc.id ) );
			flash.put( "message", "Time entry deleted." );
		} catch ( validation e ) {
			flash.put( "message", e.message );
			flash.put( "messageType", "danger" );
		}
		relocate( "timeentries" );
	}

}
