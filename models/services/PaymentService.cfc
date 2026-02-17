/**
 * PaymentService
 *
 * CRUD operations for payment records.
 * Automatically updates invoice status when payments are recorded or deleted.
 */
component singleton accessors="true" {

	property name="invoiceService" inject="InvoiceService";

	/**
	 * List all payments for an invoice
	 *
	 * @invoiceId The invoice ID
	 *
	 * @return query
	 */
	function listByInvoice( required numeric invoiceId ) {
		return queryExecute(
			"SELECT id, invoice_id, payment_date, amount, method, reference_number, notes, created_at
			 FROM payments
			 WHERE invoice_id = :invoiceId
			 ORDER BY payment_date DESC",
			{ invoiceId: { value: arguments.invoiceId, cfsqltype: "cf_sql_integer" } }
		);
	}

	/**
	 * Get total amount paid for an invoice
	 *
	 * @invoiceId The invoice ID
	 *
	 * @return numeric
	 */
	function getTotalPaid( required numeric invoiceId ) {
		var result = queryExecute(
			"SELECT COALESCE( SUM( amount ), 0 ) AS total_paid
			 FROM payments
			 WHERE invoice_id = :invoiceId",
			{ invoiceId: { value: arguments.invoiceId, cfsqltype: "cf_sql_integer" } }
		);
		return result.total_paid;
	}

	/**
	 * Record a payment and auto-update invoice status
	 *
	 * @data Struct containing invoice_id, payment_date, amount, method, reference_number, notes
	 *
	 * @return numeric The new payment ID
	 */
	function create( required struct data ) {
		if ( !val( arguments.data.amount ?: 0 ) ) {
			throw( type = "validation", message = "Payment amount must be greater than zero." );
		}

		queryExecute(
			"INSERT INTO payments ( invoice_id, payment_date, amount, method, reference_number, notes )
			 VALUES ( :invoice_id, :payment_date, :amount, :method, :reference_number, :notes )",
			{
				invoice_id: { value: arguments.data.invoice_id, cfsqltype: "cf_sql_integer" },
				payment_date: { value: arguments.data.payment_date, cfsqltype: "cf_sql_date" },
				amount: { value: arguments.data.amount, cfsqltype: "cf_sql_decimal" },
				method: { value: arguments.data.method ?: "", cfsqltype: "cf_sql_varchar", null: !len( trim( arguments.data.method ?: "" ) ) },
				reference_number: { value: trim( arguments.data.reference_number ?: "" ), cfsqltype: "cf_sql_varchar", null: !len( trim( arguments.data.reference_number ?: "" ) ) },
				notes: { value: trim( arguments.data.notes ?: "" ), cfsqltype: "cf_sql_varchar", null: !len( trim( arguments.data.notes ?: "" ) ) }
			},
			{ result: "local.insertResult" }
		);

		// Auto-update invoice status
		invoiceService.recalculateStatus( arguments.data.invoice_id );

		return local.insertResult.generatedKey;
	}

	/**
	 * Delete a payment and auto-update invoice status
	 *
	 * @id        The payment ID
	 * @invoiceId The parent invoice ID
	 */
	function delete( required numeric id, required numeric invoiceId ) {
		queryExecute(
			"DELETE FROM payments WHERE id = :id",
			{ id: { value: arguments.id, cfsqltype: "cf_sql_integer" } }
		);

		// Auto-update invoice status
		invoiceService.recalculateStatus( arguments.invoiceId );
	}

}
