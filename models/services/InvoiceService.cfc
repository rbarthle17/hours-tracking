/**
 * InvoiceService
 *
 * CRUD and business logic for invoice records.
 * Handles invoice generation, line item creation, and status management.
 */
component singleton accessors="true" {

	/**
	 * List all invoices with client name, optionally filtered
	 *
	 * @clientId Optional client ID filter
	 * @status   Optional status filter
	 *
	 * @return query
	 */
	function list( numeric clientId = 0, string status = "" ) {
		var sql = "SELECT i.id, i.client_id, i.invoice_number, i.invoice_date, i.due_date,
						  i.total_amount, i.status, i.notes, i.created_at,
						  cl.name AS client_name,
						  COALESCE( SUM( p.amount ), 0 ) AS total_paid
				   FROM invoices i
				   JOIN clients cl ON i.client_id = cl.id
				   LEFT JOIN payments p ON i.id = p.invoice_id
				   WHERE 1=1";
		var params = {};

		if ( arguments.clientId > 0 ) {
			sql &= " AND i.client_id = :clientId";
			params.clientId = { value: arguments.clientId, cfsqltype: "cf_sql_integer" };
		}

		if ( len( trim( arguments.status ) ) ) {
			sql &= " AND i.status = :status";
			params.status = { value: arguments.status, cfsqltype: "cf_sql_varchar" };
		}

		sql &= " GROUP BY i.id, i.client_id, i.invoice_number, i.invoice_date, i.due_date,
				  i.total_amount, i.status, i.notes, i.created_at, cl.name
				  ORDER BY i.invoice_date DESC, i.created_at DESC";

		return queryExecute( sql, params );
	}

	/**
	 * Get a single invoice by ID with client name and payment totals
	 *
	 * @id The invoice ID
	 *
	 * @return query
	 */
	function get( required numeric id ) {
		return queryExecute(
			"SELECT i.id, i.client_id, i.invoice_number, i.invoice_date, i.due_date,
					i.total_amount, i.status, i.notes, i.created_at, i.updated_at,
					cl.name AS client_name, cl.email AS client_email,
					cl.address AS client_address,
					COALESCE( ( SELECT SUM( p.amount ) FROM payments p WHERE p.invoice_id = i.id ), 0 ) AS total_paid
			 FROM invoices i
			 JOIN clients cl ON i.client_id = cl.id
			 WHERE i.id = :id",
			{ id: { value: arguments.id, cfsqltype: "cf_sql_integer" } }
		);
	}

	/**
	 * Get line items for an invoice
	 *
	 * @invoiceId The invoice ID
	 *
	 * @return query
	 */
	function getLineItems( required numeric invoiceId ) {
		return queryExecute(
			"SELECT ili.id, ili.invoice_id, ili.contract_id, ili.time_entry_id,
					ili.hours, ili.rate, ili.description, ili.subtotal, ili.created_at,
					c.name AS contract_name
			 FROM invoice_line_items ili
			 JOIN contracts c ON ili.contract_id = c.id
			 WHERE ili.invoice_id = :invoiceId
			 ORDER BY ili.created_at ASC",
			{ invoiceId: { value: arguments.invoiceId, cfsqltype: "cf_sql_integer" } }
		);
	}

	/**
	 * Generate next invoice number in format INV-YYYY-NNNN
	 *
	 * @return string
	 */
	function generateNumber() {
		var year = year( now() );
		var lastInvoice = queryExecute(
			"SELECT invoice_number
			 FROM invoices
			 WHERE invoice_number LIKE :prefix
			 ORDER BY invoice_number DESC
			 LIMIT 1",
			{ prefix: { value: "INV-#year#-%", cfsqltype: "cf_sql_varchar" } }
		);

		if ( lastInvoice.recordCount ) {
			var lastNum = val( listLast( lastInvoice.invoice_number, "-" ) );
			return "INV-#year#-#numberFormat( lastNum + 1, '0000' )#";
		}

		return "INV-#year#-0001";
	}

	/**
	 * Create an invoice from selected time entries.
	 * Wraps invoice creation + line item creation in a transaction.
	 *
	 * @clientId     The client ID
	 * @timeEntryIds Array of time entry IDs to include
	 * @invoiceDate  The invoice date
	 * @dueDate      The due date
	 * @notes        Optional notes
	 *
	 * @return numeric The new invoice ID
	 */
	function createFromTimeEntries(
		required numeric clientId,
		required array timeEntryIds,
		required string invoiceDate,
		required string dueDate,
		string notes = ""
	) {
		if ( !arrayLen( arguments.timeEntryIds ) ) {
			throw( type = "validation", message = "At least one time entry must be selected." );
		}

		var invoiceId = 0;

		transaction {
			var invoiceNumber = generateNumber();

			queryExecute(
				"INSERT INTO invoices ( client_id, invoice_number, invoice_date, due_date, total_amount, status, notes )
				 VALUES ( :client_id, :invoice_number, :invoice_date, :due_date, 0, 'draft', :notes )",
				{
					client_id: { value: arguments.clientId, cfsqltype: "cf_sql_integer" },
					invoice_number: { value: invoiceNumber, cfsqltype: "cf_sql_varchar" },
					invoice_date: { value: arguments.invoiceDate, cfsqltype: "cf_sql_date" },
					due_date: { value: arguments.dueDate, cfsqltype: "cf_sql_date" },
					notes: { value: trim( arguments.notes ), cfsqltype: "cf_sql_varchar", null: !len( trim( arguments.notes ) ) }
				},
				{ result: "local.insertResult" }
			);

			invoiceId = local.insertResult.generatedKey;

			// Fetch the selected time entries with their contract rates
			var placeholders = [];
			var teParams = { invoiceId: { value: invoiceId, cfsqltype: "cf_sql_integer" } };
			for ( var i = 1; i <= arrayLen( arguments.timeEntryIds ); i++ ) {
				arrayAppend( placeholders, ":te_#i#" );
				teParams[ "te_#i#" ] = { value: arguments.timeEntryIds[ i ], cfsqltype: "cf_sql_integer" };
			}

			var entries = queryExecute(
				"SELECT te.id, te.hours_worked, te.notes,
						t.title AS ticket_title, t.contract_id,
						c.hourly_rate
				 FROM time_entries te
				 JOIN tickets t ON te.ticket_id = t.id
				 JOIN contracts c ON t.contract_id = c.id
				 WHERE te.id IN ( #arrayToList( placeholders )# )",
				teParams
			);

			// Create line items for each time entry
			var totalAmount = 0;
			for ( var entry in entries ) {
				var subtotal = entry.hours_worked * entry.hourly_rate;
				totalAmount += subtotal;

				var description = entry.ticket_title;
				if ( len( entry.notes ?: "" ) ) {
					description &= " - " & entry.notes;
				}

				queryExecute(
					"INSERT INTO invoice_line_items ( invoice_id, contract_id, time_entry_id, hours, rate, description, subtotal )
					 VALUES ( :invoice_id, :contract_id, :time_entry_id, :hours, :rate, :description, :subtotal )",
					{
						invoice_id: { value: invoiceId, cfsqltype: "cf_sql_integer" },
						contract_id: { value: entry.contract_id, cfsqltype: "cf_sql_integer" },
						time_entry_id: { value: entry.id, cfsqltype: "cf_sql_integer" },
						hours: { value: entry.hours_worked, cfsqltype: "cf_sql_decimal" },
						rate: { value: entry.hourly_rate, cfsqltype: "cf_sql_decimal" },
						description: { value: description, cfsqltype: "cf_sql_varchar" },
						subtotal: { value: subtotal, cfsqltype: "cf_sql_decimal" }
					}
				);
			}

			// Update the invoice total
			queryExecute(
				"UPDATE invoices SET total_amount = :total WHERE id = :id",
				{
					total: { value: totalAmount, cfsqltype: "cf_sql_decimal" },
					id: { value: invoiceId, cfsqltype: "cf_sql_integer" }
				}
			);
		}

		return invoiceId;
	}

	/**
	 * Update invoice dates and notes (draft only)
	 *
	 * @id   The invoice ID
	 * @data Struct containing invoice_date, due_date, notes
	 */
	function update( required numeric id, required struct data ) {
		var invoice = get( arguments.id );
		if ( invoice.status != "draft" ) {
			throw( type = "validation", message = "Only draft invoices can be edited." );
		}

		queryExecute(
			"UPDATE invoices
			 SET invoice_date = :invoice_date, due_date = :due_date, notes = :notes
			 WHERE id = :id",
			{
				id: { value: arguments.id, cfsqltype: "cf_sql_integer" },
				invoice_date: { value: arguments.data.invoice_date, cfsqltype: "cf_sql_date" },
				due_date: { value: arguments.data.due_date, cfsqltype: "cf_sql_date" },
				notes: { value: trim( arguments.data.notes ?: "" ), cfsqltype: "cf_sql_varchar", null: !len( trim( arguments.data.notes ?: "" ) ) }
			}
		);
	}

	/**
	 * Update invoice status
	 *
	 * @id     The invoice ID
	 * @status The new status
	 */
	function updateStatus( required numeric id, required string status ) {
		queryExecute(
			"UPDATE invoices SET status = :status WHERE id = :id",
			{
				id: { value: arguments.id, cfsqltype: "cf_sql_integer" },
				status: { value: arguments.status, cfsqltype: "cf_sql_varchar" }
			}
		);
	}

	/**
	 * Auto-update invoice status based on payments.
	 * Called after a payment is recorded or deleted.
	 *
	 * @id The invoice ID
	 */
	function recalculateStatus( required numeric id ) {
		var invoice = get( arguments.id );
		if ( !invoice.recordCount ) return;

		// Don't change status of draft invoices
		if ( invoice.status == "draft" ) return;

		var totalPaid = invoice.total_paid;
		var totalAmount = invoice.total_amount;

		if ( totalPaid >= totalAmount ) {
			updateStatus( arguments.id, "paid" );
		} else if ( totalPaid > 0 ) {
			updateStatus( arguments.id, "partial" );
		} else {
			// If no payments but was previously paid/partial, revert to sent
			if ( listFindNoCase( "paid,partial", invoice.status ) ) {
				updateStatus( arguments.id, "sent" );
			}
		}
	}

	/**
	 * Delete a draft invoice and its line items (CASCADE handles line items)
	 *
	 * @id The invoice ID
	 */
	function delete( required numeric id ) {
		var invoice = get( arguments.id );
		if ( invoice.status != "draft" ) {
			throw( type = "validation", message = "Only draft invoices can be deleted." );
		}

		queryExecute(
			"DELETE FROM invoices WHERE id = :id",
			{ id: { value: arguments.id, cfsqltype: "cf_sql_integer" } }
		);
	}

}
