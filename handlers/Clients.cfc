/**
 * Clients Handler
 *
 * CRUD operations for managing client records.
 */
component extends="coldbox.system.EventHandler" {

	property name="clientService" inject="ClientService";
	property name="contractService" inject="ContractService";
	property name="ticketService" inject="TicketService";

	/**
	 * List all clients
	 */
	function index( event, rc, prc ) {
		prc.clients = clientService.list( rc.search ?: "" );
		event.setView( "clients/index" );
	}

	/**
	 * Display the new client form
	 */
	function new( event, rc, prc ) {
		event.setView( "clients/new" );
	}

	/**
	 * Create a new client
	 */
	function create( event, rc, prc ) {
		try {
			var newId = clientService.create( rc );
			flash.put( "message", "Client created successfully." );
			relocate( "clients.show", { id: newId } );
		} catch ( validation e ) {
			flash.put( "message", e.message );
			flash.put( "messageType", "danger" );
			relocate( "clients.new" );
		}
	}

	/**
	 * Display a single client
	 */
	function show( event, rc, prc ) {
		prc.client = clientService.get( rc.id );
		if ( !prc.client.recordCount ) {
			flash.put( "message", "Client not found." );
			flash.put( "messageType", "danger" );
			relocate( "clients" );
		}
		prc.contracts = contractService.listByClient( rc.id );
		prc.tickets = ticketService.listByClient( rc.id );
		event.setView( "clients/show" );
	}

	/**
	 * Display the edit client form
	 */
	function edit( event, rc, prc ) {
		prc.client = clientService.get( rc.id );
		if ( !prc.client.recordCount ) {
			flash.put( "message", "Client not found." );
			flash.put( "messageType", "danger" );
			relocate( "clients" );
		}
		event.setView( "clients/edit" );
	}

	/**
	 * Update an existing client
	 */
	function update( event, rc, prc ) {
		try {
			clientService.update( rc.id, rc );
			flash.put( "message", "Client updated successfully." );
			relocate( "clients.show", { id: rc.id } );
		} catch ( validation e ) {
			flash.put( "message", e.message );
			flash.put( "messageType", "danger" );
			relocate( "clients.edit", { id: rc.id } );
		}
	}

	/**
	 * Delete a client
	 */
	function delete( event, rc, prc ) {
		try {
			clientService.delete( rc.id );
			flash.put( "message", "Client deleted." );
		} catch ( database e ) {
			flash.put( "message", "Cannot delete client: they have associated contracts or tickets." );
			flash.put( "messageType", "danger" );
		}
		relocate( "clients" );
	}

}
