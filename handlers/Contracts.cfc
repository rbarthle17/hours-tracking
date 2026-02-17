/**
 * Contracts Handler
 *
 * CRUD operations for managing contract records.
 */
component extends="coldbox.system.EventHandler" {

	property name="contractService" inject="ContractService";
	property name="clientService" inject="ClientService";
	property name="timeEntryService" inject="TimeEntryService";

	/**
	 * List all contracts
	 */
	function index( event, rc, prc ) {
		prc.contracts = contractService.list(
			clientId = val( rc.client_id ?: 0 ),
			status   = rc.status ?: ""
		);
		prc.clients = clientService.list();
		event.setView( "contracts/index" );
	}

	/**
	 * Display the new contract form
	 */
	function new( event, rc, prc ) {
		prc.clients = clientService.list();
		event.setView( "contracts/new" );
	}

	/**
	 * Create a new contract
	 */
	function create( event, rc, prc ) {
		try {
			var newId = contractService.create( rc );
			flash.put( "message", "Contract created successfully." );
			relocate( "contracts.show", { id: newId } );
		} catch ( validation e ) {
			flash.put( "message", e.message );
			flash.put( "messageType", "danger" );
			relocate( "contracts.new" );
		}
	}

	/**
	 * Display a single contract
	 */
	function show( event, rc, prc ) {
		prc.contract = contractService.get( rc.id );
		if ( !prc.contract.recordCount ) {
			flash.put( "message", "Contract not found." );
			flash.put( "messageType", "danger" );
			relocate( "contracts" );
		}
		prc.timeEntries = timeEntryService.listByContract( rc.id );
		event.setView( "contracts/show" );
	}

	/**
	 * Display the edit contract form
	 */
	function edit( event, rc, prc ) {
		prc.contract = contractService.get( rc.id );
		if ( !prc.contract.recordCount ) {
			flash.put( "message", "Contract not found." );
			flash.put( "messageType", "danger" );
			relocate( "contracts" );
		}
		prc.clients = clientService.list();
		event.setView( "contracts/edit" );
	}

	/**
	 * Update an existing contract
	 */
	function update( event, rc, prc ) {
		try {
			contractService.update( rc.id, rc );
			flash.put( "message", "Contract updated successfully." );
			relocate( "contracts.show", { id: rc.id } );
		} catch ( validation e ) {
			flash.put( "message", e.message );
			flash.put( "messageType", "danger" );
			relocate( "contracts.edit", { id: rc.id } );
		}
	}

	/**
	 * Delete a contract
	 */
	function delete( event, rc, prc ) {
		try {
			contractService.delete( rc.id );
			flash.put( "message", "Contract deleted." );
		} catch ( database e ) {
			flash.put( "message", "Cannot delete contract: it has associated time entries." );
			flash.put( "messageType", "danger" );
		}
		relocate( "contracts" );
	}

}
