/**
 * Payments Handler
 *
 * Nested under invoices — manages payment records for a specific invoice.
 */
component extends="coldbox.system.EventHandler" {

	property name="paymentService" inject="PaymentService";
	property name="invoiceService" inject="InvoiceService";

	/**
	 * Display the new payment form
	 */
	function new( event, rc, prc ) {
		prc.invoice = invoiceService.get( rc.invoiceId );
		if ( !prc.invoice.recordCount ) {
			flash.put( "message", "Invoice not found." );
			flash.put( "messageType", "danger" );
			relocate( "invoices" );
		}
		prc.balanceDue = prc.invoice.total_amount - prc.invoice.total_paid;
		event.setView( "payments/new" );
	}

	/**
	 * Record a payment
	 */
	function create( event, rc, prc ) {
		try {
			rc.invoice_id = rc.invoiceId;
			paymentService.create( rc );
			flash.put( "message", "Payment recorded successfully." );
		} catch ( validation e ) {
			flash.put( "message", e.message );
			flash.put( "messageType", "danger" );
		}
		relocate( "invoices.show", { id: rc.invoiceId } );
	}

	/**
	 * Delete a payment
	 */
	function delete( event, rc, prc ) {
		paymentService.delete( rc.id, rc.invoiceId );
		flash.put( "message", "Payment deleted." );
		relocate( "invoices.show", { id: rc.invoiceId } );
	}

}
