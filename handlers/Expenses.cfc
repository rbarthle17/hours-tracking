/**
 * Expenses Handler
 *
 * CRUD operations and CSV export for expense records.
 * Supports general business expenses and client-linked billable expenses.
 */
component extends="coldbox.system.EventHandler" {

	property name="expenseService" inject="ExpenseService";
	property name="clientService" inject="ClientService";

	/**
	 * List all expenses with optional filters
	 */
	function index( event, rc, prc ) {
		prc.expenses = expenseService.list(
			clientId = val( rc.client_id ?: 0 ),
			category = rc.category ?: "",
			startDate = rc.start_date ?: "",
			endDate = rc.end_date ?: "",
			billable = rc.billable ?: ""
		);
		prc.clients = clientService.list();
		prc.categories = expenseService.getCategories();
		event.setView( "expenses/index" );
	}

	/**
	 * Display the new expense form
	 */
	function new( event, rc, prc ) {
		prc.clients = clientService.list();
		prc.categories = expenseService.getCategories();
		event.setView( "expenses/new" );
	}

	/**
	 * Create a new expense record
	 */
	function create( event, rc, prc ) {
		try {
			var newId = expenseService.create( rc );
			flash.put( "message", "Expense saved successfully." );
			relocate( "expenses/#newId#" );
		} catch ( validation e ) {
			flash.put( "message", e.message );
			flash.put( "messageType", "danger" );
			relocate( "expenses.new" );
		}
	}

	/**
	 * Display a single expense
	 */
	function show( event, rc, prc ) {
		prc.expense = expenseService.get( val( rc.id ) );
		if ( !prc.expense.recordCount ) {
			flash.put( "message", "Expense not found." );
			flash.put( "messageType", "danger" );
			relocate( "expenses" );
		}
		event.setView( "expenses/show" );
	}

	/**
	 * Display the edit expense form
	 */
	function edit( event, rc, prc ) {
		prc.expense = expenseService.get( val( rc.id ) );
		if ( !prc.expense.recordCount ) {
			flash.put( "message", "Expense not found." );
			flash.put( "messageType", "danger" );
			relocate( "expenses" );
		}
		prc.clients = clientService.list();
		prc.categories = expenseService.getCategories();
		event.setView( "expenses/edit" );
	}

	/**
	 * Update an existing expense
	 */
	function update( event, rc, prc ) {
		try {
			expenseService.update( val( rc.id ), rc );
			flash.put( "message", "Expense updated successfully." );
			relocate( "expenses/#rc.id#" );
		} catch ( validation e ) {
			flash.put( "message", e.message );
			flash.put( "messageType", "danger" );
			relocate( "expenses/#rc.id#/edit" );
		}
	}

	/**
	 * Delete an expense
	 */
	function delete( event, rc, prc ) {
		try {
			expenseService.delete( val( rc.id ) );
			flash.put( "message", "Expense deleted." );
		} catch ( validation e ) {
			flash.put( "message", e.message );
			flash.put( "messageType", "danger" );
		}
		relocate( "expenses" );
	}

	/**
	 * Export expenses to CSV with the same filters as the index view
	 */
	function export( event, rc, prc ) {
		var expenses = expenseService.getForExport(
			clientId = val( rc.client_id ?: 0 ),
			category = rc.category ?: "",
			startDate = rc.start_date ?: "",
			endDate = rc.end_date ?: "",
			billable = rc.billable ?: ""
		);
		var csv = expenseService.buildExpenseCSV( expenses );
		var filename = "expenses-#dateFormat( now(), 'yyyy-mm-dd' )#.csv";
		event.setHTTPHeader( name = "Content-Disposition", value = 'attachment;filename="#filename#"' );
		event.renderData( type = "text", data = csv );
	}

	/**
	 * Export a monthly P&L summary combining revenue and expenses to CSV
	 */
	function pnl( event, rc, prc ) {
		var data = expenseService.getMonthlyProfitLoss();
		var csv = expenseService.buildProfitLossCSV( data );
		var filename = "profit-loss-#dateFormat( now(), 'yyyy-mm-dd' )#.csv";
		event.setHTTPHeader( name = "Content-Disposition", value = 'attachment;filename="#filename#"' );
		event.renderData( type = "text", data = csv );
	}

}
