/**
 * Main Handler
 *
 * Handles the dashboard and application lifecycle events including authentication checks.
 */
component extends="coldbox.system.EventHandler" {

	// Public routes that do not require authentication
	this.PUBLIC_ROUTES = [ "Auth.loginForm", "Auth.login", "Auth.logout" ];

	/**
	 * Dashboard — summary stats, recent entries, outstanding invoices
	 */
	function index( event, rc, prc ) {
		// Active contracts count
		prc.activeContracts = queryExecute(
			"SELECT COUNT( id ) AS cnt FROM contracts WHERE status = 'active'"
		);

		// Hours this month
		prc.hoursThisMonth = queryExecute(
			"SELECT COALESCE( SUM( hours_worked ), 0 ) AS total_hours
			 FROM time_entries
			 WHERE MONTH( entry_date ) = MONTH( CURDATE() )
			   AND YEAR( entry_date ) = YEAR( CURDATE() )"
		);

		// Outstanding balance (sent + partial + overdue invoices)
		prc.outstandingBalance = queryExecute(
			"SELECT COALESCE( SUM( i.total_amount ) - COALESCE( SUM( p.amount ), 0 ), 0 ) AS balance
			 FROM invoices i
			 LEFT JOIN payments p ON i.id = p.invoice_id
			 WHERE i.status IN ( 'sent', 'partial', 'overdue' )"
		);

		// Revenue this month (payments received this month)
		prc.monthlyRevenue = queryExecute(
			"SELECT COALESCE( SUM( amount ), 0 ) AS revenue
			 FROM payments
			 WHERE MONTH( payment_date ) = MONTH( CURDATE() )
			   AND YEAR( payment_date ) = YEAR( CURDATE() )"
		);

		// Recent time entries (last 10)
		prc.recentEntries = queryExecute(
			"SELECT te.id, te.entry_date, te.hours_worked, te.notes,
					t.title AS ticket_title, t.id AS ticket_id,
					cl.name AS client_name,
					c.name AS contract_name, c.hourly_rate
			 FROM time_entries te
			 JOIN tickets t ON te.ticket_id = t.id
			 JOIN contracts c ON te.contract_id = c.id
			 JOIN clients cl ON t.client_id = cl.id
			 ORDER BY te.entry_date DESC, te.created_at DESC
			 LIMIT 10"
		);

		// Outstanding invoices
		prc.outstandingInvoices = queryExecute(
			"SELECT i.id, i.invoice_number, i.invoice_date, i.due_date,
					i.total_amount, i.status,
					cl.name AS client_name,
					COALESCE( ( SELECT SUM( p.amount ) FROM payments p WHERE p.invoice_id = i.id ), 0 ) AS total_paid
			 FROM invoices i
			 JOIN clients cl ON i.client_id = cl.id
			 WHERE i.status IN ( 'sent', 'partial', 'overdue' )
			 ORDER BY i.due_date ASC"
		);

		event.setView( "main/index" );
	}

	/**
	 * --------------------------------------------------------------------------
	 * Implicit Actions
	 * --------------------------------------------------------------------------
	 */

	function onAppInit( event, rc, prc ) {
	}

	/**
	 * Runs before every request. Enforces authentication on protected routes.
	 */
	function onRequestStart( event, rc, prc ) {
		// Allow healthcheck through without auth
		if ( findNoCase( "healthcheck", event.getCurrentEvent() ) ) {
			return;
		}

		// Check if the current route is public
		var currentEvent = event.getCurrentEvent();
		for ( var publicRoute in this.PUBLIC_ROUTES ) {
			if ( currentEvent == publicRoute ) {
				return;
			}
		}

		// If not authenticated, redirect to login
		if ( !structKeyExists( session, "user" ) ) {
			relocate( "auth.loginForm" );
		}

		// Make the current user available in the private request collection
		prc.currentUser = session.user;
	}

	function onRequestEnd( event, rc, prc ) {
	}

	function onSessionStart( event, rc, prc ) {
	}

	function onSessionEnd( event, rc, prc ) {
		var sessionScope     = event.getValue( "sessionReference" );
		var applicationScope = event.getValue( "applicationReference" );
	}

	function onException( event, rc, prc ) {
		event.setHTTPHeader( statusCode = 500 );
		var exception = prc.exception;
	}

}
