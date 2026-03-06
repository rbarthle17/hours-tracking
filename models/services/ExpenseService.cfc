/**
 * ExpenseService
 *
 * CRUD operations and reporting for expense records.
 * Expenses may be general business expenses or linked to a specific client.
 * Billable expenses are surfaced when creating invoices for a client.
 */
component singleton accessors="true" {

	/**
	 * Expense categories — edit this array to change available categories.
	 * VARCHAR(100) column, so adding/removing categories needs no schema change.
	 */
	variables.CATEGORIES = [
		"Software/Subscriptions",
		"Hosting/Infrastructure",
		"Hardware",
		"Home Office",
		"Professional Services",
		"Travel",
		"Education/Training",
		"Other"
	];

	/**
	 * Return the list of expense categories
	 *
	 * @return array
	 */
	function getCategories() {
		return variables.CATEGORIES;
	}

	/**
	 * List expenses with optional filters
	 *
	 * @clientId   Optional client ID filter (0 = all)
	 * @category   Optional category filter
	 * @startDate  Optional start date filter
	 * @endDate    Optional end date filter
	 * @billable   Optional filter: "1" = billable only, "" = all
	 *
	 * @return query
	 */
	function list(
		numeric clientId = 0,
		string category = "",
		string startDate = "",
		string endDate = "",
		string billable = ""
	) {
		var sql = "SELECT e.id, e.client_id, e.expense_date, e.vendor, e.amount,
						  e.category, e.description, e.receipt_reference,
						  e.is_billable, e.is_invoiced, e.created_at,
						  cl.name AS client_name
				   FROM expenses e
				   LEFT JOIN clients cl ON e.client_id = cl.id
				   WHERE 1=1";
		var params = {};

		if ( arguments.clientId > 0 ) {
			sql &= " AND e.client_id = :clientId";
			params.clientId = { value: arguments.clientId, cfsqltype: "cf_sql_integer" };
		}

		if ( len( trim( arguments.category ) ) ) {
			sql &= " AND e.category = :category";
			params.category = { value: trim( arguments.category ), cfsqltype: "cf_sql_varchar" };
		}

		if ( len( trim( arguments.startDate ) ) ) {
			sql &= " AND e.expense_date >= :startDate";
			params.startDate = { value: arguments.startDate, cfsqltype: "cf_sql_date" };
		}

		if ( len( trim( arguments.endDate ) ) ) {
			sql &= " AND e.expense_date <= :endDate";
			params.endDate = { value: arguments.endDate, cfsqltype: "cf_sql_date" };
		}

		if ( arguments.billable == "1" ) {
			sql &= " AND e.is_billable = 1";
		}

		sql &= " ORDER BY e.expense_date DESC, e.created_at DESC";

		return queryExecute( sql, params );
	}

	/**
	 * Get a single expense by ID
	 *
	 * @id The expense ID
	 *
	 * @return query
	 */
	function get( required numeric id ) {
		return queryExecute(
			"SELECT e.id, e.client_id, e.expense_date, e.vendor, e.amount,
					e.category, e.description, e.receipt_reference,
					e.is_billable, e.is_invoiced, e.created_at, e.updated_at,
					cl.name AS client_name
			 FROM expenses e
			 LEFT JOIN clients cl ON e.client_id = cl.id
			 WHERE e.id = :id",
			{ id: { value: arguments.id, cfsqltype: "cf_sql_integer" } }
		);
	}

	/**
	 * Get unbilled billable expenses for a specific client.
	 * Used by invoice creation to surface expenses that haven't been invoiced.
	 *
	 * @clientId The client ID
	 *
	 * @return query
	 */
	function getUnbilledByClient( required numeric clientId ) {
		return queryExecute(
			"SELECT id, expense_date, vendor, amount, category, description
			 FROM expenses
			 WHERE client_id = :clientId
			   AND is_billable = 1
			   AND is_invoiced = 0
			 ORDER BY expense_date ASC",
			{ clientId: { value: arguments.clientId, cfsqltype: "cf_sql_integer" } }
		);
	}

	/**
	 * Get expenses for CSV export, accepting the same filters as list().
	 * Returns all matching expenses with client name for the export file.
	 *
	 * @clientId   Optional client ID filter
	 * @category   Optional category filter
	 * @startDate  Optional start date filter
	 * @endDate    Optional end date filter
	 * @billable   Optional billable-only filter
	 *
	 * @return query
	 */
	function getForExport(
		numeric clientId = 0,
		string category = "",
		string startDate = "",
		string endDate = "",
		string billable = ""
	) {
		return list(
			clientId = arguments.clientId,
			category = arguments.category,
			startDate = arguments.startDate,
			endDate = arguments.endDate,
			billable = arguments.billable
		);
	}

	/**
	 * Get monthly profit and loss data combining invoice revenue with expenses.
	 * Revenue = total_amount from sent, paid, and partial invoices.
	 * Expenses = sum of expense amounts.
	 * Uses UNION ALL + GROUP BY to simulate a full outer join (MySQL-compatible).
	 *
	 * @return query with columns: month_label, total_revenue, total_expenses, net
	 */
	function getMonthlyProfitLoss() {
		return queryExecute(
			"SELECT
				month_label,
				SUM( total_revenue ) AS total_revenue,
				SUM( total_expenses ) AS total_expenses,
				SUM( total_revenue ) - SUM( total_expenses ) AS net
			 FROM (
				SELECT DATE_FORMAT( invoice_date, '%Y-%m' ) AS month_label,
					   SUM( total_amount ) AS total_revenue,
					   0 AS total_expenses
				FROM invoices
				WHERE status IN ( 'paid', 'partial', 'sent' )
				GROUP BY DATE_FORMAT( invoice_date, '%Y-%m' )

				UNION ALL

				SELECT DATE_FORMAT( expense_date, '%Y-%m' ) AS month_label,
					   0 AS total_revenue,
					   SUM( amount ) AS total_expenses
				FROM expenses
				GROUP BY DATE_FORMAT( expense_date, '%Y-%m' )
			 ) combined
			 GROUP BY month_label
			 ORDER BY month_label DESC"
		);
	}

	/**
	 * Build a CSV string from an expense query result.
	 * Used by the export handler action.
	 *
	 * @expenses Query result from list() or getForExport()
	 *
	 * @return string
	 */
	function buildExpenseCSV( required query expenses ) {
		var lines = [];
		arrayAppend( lines, '"Date","Vendor","Category","Client","Amount","Billable","Invoiced","Description","Receipt Reference"' );

		for ( var row in arguments.expenses ) {
			var line = '"#dateFormat( row.expense_date, "yyyy-mm-dd" )#"';
			line &= ',"#replace( row.vendor, '"', '""', 'all' )#"';
			line &= ',"#replace( row.category, '"', '""', 'all' )#"';
			line &= ',"#replace( row.client_name ?: '', '"', '""', 'all' )#"';
			line &= ',#numberFormat( row.amount, "0.00" )#';
			line &= ',"#row.is_billable ? "Yes" : "No"#"';
			line &= ',"#row.is_invoiced ? "Yes" : "No"#"';
			line &= ',"#replace( row.description ?: '', '"', '""', 'all' )#"';
			line &= ',"#replace( row.receipt_reference ?: '', '"', '""', 'all' )#"';
			arrayAppend( lines, line );
		}

		return arrayToList( lines, chr(10) );
	}

	/**
	 * Build a CSV string from the monthly P&L query result.
	 *
	 * @data Query result from getMonthlyProfitLoss()
	 *
	 * @return string
	 */
	function buildProfitLossCSV( required query data ) {
		var lines = [];
		arrayAppend( lines, '"Month","Revenue","Expenses","Net Profit/Loss"' );

		for ( var row in arguments.data ) {
			var line = '"#row.month_label#"';
			line &= ',#numberFormat( row.total_revenue, "0.00" )#';
			line &= ',#numberFormat( row.total_expenses, "0.00" )#';
			line &= ',#numberFormat( row.net, "0.00" )#';
			arrayAppend( lines, line );
		}

		return arrayToList( lines, chr(10) );
	}

	/**
	 * Create a new expense record
	 *
	 * @data Struct containing expense fields from the request collection
	 *
	 * @return numeric The new expense ID
	 */
	function create( required struct data ) {
		if ( !len( trim( arguments.data.vendor ?: "" ) ) ) {
			throw( type = "validation", message = "Vendor/payee is required." );
		}
		if ( !val( arguments.data.amount ?: 0 ) || val( arguments.data.amount ) <= 0 ) {
			throw( type = "validation", message = "Amount must be greater than zero." );
		}
		if ( !len( trim( arguments.data.category ?: "" ) ) ) {
			throw( type = "validation", message = "Category is required." );
		}
		if ( !len( trim( arguments.data.expense_date ?: "" ) ) ) {
			throw( type = "validation", message = "Date is required." );
		}

		var isBillable = ( arguments.data.is_billable ?: "0" ) == "1";
		if ( isBillable && !val( arguments.data.client_id ?: 0 ) ) {
			throw( type = "validation", message = "A client must be selected for billable expenses." );
		}

		queryExecute(
			"INSERT INTO expenses ( client_id, expense_date, vendor, amount, category,
									description, receipt_reference, is_billable )
			 VALUES ( :client_id, :expense_date, :vendor, :amount, :category,
					  :description, :receipt_reference, :is_billable )",
			{
				client_id: { value: val( arguments.data.client_id ?: 0 ), cfsqltype: "cf_sql_integer", null: !val( arguments.data.client_id ?: 0 ) },
				expense_date: { value: arguments.data.expense_date, cfsqltype: "cf_sql_date" },
				vendor: { value: trim( arguments.data.vendor ), cfsqltype: "cf_sql_varchar" },
				amount: { value: arguments.data.amount, cfsqltype: "cf_sql_decimal" },
				category: { value: trim( arguments.data.category ), cfsqltype: "cf_sql_varchar" },
				description: { value: trim( arguments.data.description ?: "" ), cfsqltype: "cf_sql_longvarchar", null: !len( trim( arguments.data.description ?: "" ) ) },
				receipt_reference: { value: trim( arguments.data.receipt_reference ?: "" ), cfsqltype: "cf_sql_varchar", null: !len( trim( arguments.data.receipt_reference ?: "" ) ) },
				is_billable: { value: isBillable ? 1 : 0, cfsqltype: "cf_sql_bit" }
			},
			{ result: "local.insertResult" }
		);

		return local.insertResult.generatedKey;
	}

	/**
	 * Update an existing expense record
	 *
	 * @id   The expense ID
	 * @data Struct containing updated expense fields
	 */
	function update( required numeric id, required struct data ) {
		if ( !len( trim( arguments.data.vendor ?: "" ) ) ) {
			throw( type = "validation", message = "Vendor/payee is required." );
		}
		if ( !val( arguments.data.amount ?: 0 ) || val( arguments.data.amount ) <= 0 ) {
			throw( type = "validation", message = "Amount must be greater than zero." );
		}
		if ( !len( trim( arguments.data.category ?: "" ) ) ) {
			throw( type = "validation", message = "Category is required." );
		}
		if ( !len( trim( arguments.data.expense_date ?: "" ) ) ) {
			throw( type = "validation", message = "Date is required." );
		}

		var isBillable = ( arguments.data.is_billable ?: "0" ) == "1";
		if ( isBillable && !val( arguments.data.client_id ?: 0 ) ) {
			throw( type = "validation", message = "A client must be selected for billable expenses." );
		}

		queryExecute(
			"UPDATE expenses
			 SET client_id = :client_id, expense_date = :expense_date, vendor = :vendor,
				 amount = :amount, category = :category, description = :description,
				 receipt_reference = :receipt_reference, is_billable = :is_billable
			 WHERE id = :id",
			{
				id: { value: arguments.id, cfsqltype: "cf_sql_integer" },
				client_id: { value: val( arguments.data.client_id ?: 0 ), cfsqltype: "cf_sql_integer", null: !val( arguments.data.client_id ?: 0 ) },
				expense_date: { value: arguments.data.expense_date, cfsqltype: "cf_sql_date" },
				vendor: { value: trim( arguments.data.vendor ), cfsqltype: "cf_sql_varchar" },
				amount: { value: arguments.data.amount, cfsqltype: "cf_sql_decimal" },
				category: { value: trim( arguments.data.category ), cfsqltype: "cf_sql_varchar" },
				description: { value: trim( arguments.data.description ?: "" ), cfsqltype: "cf_sql_longvarchar", null: !len( trim( arguments.data.description ?: "" ) ) },
				receipt_reference: { value: trim( arguments.data.receipt_reference ?: "" ), cfsqltype: "cf_sql_varchar", null: !len( trim( arguments.data.receipt_reference ?: "" ) ) },
				is_billable: { value: isBillable ? 1 : 0, cfsqltype: "cf_sql_bit" }
			}
		);
	}

	/**
	 * Delete an expense. Refuses to delete if the expense has been invoiced.
	 *
	 * @id The expense ID
	 */
	function delete( required numeric id ) {
		var expense = queryExecute(
			"SELECT is_invoiced FROM expenses WHERE id = :id",
			{ id: { value: arguments.id, cfsqltype: "cf_sql_integer" } }
		);

		if ( expense.recordCount && expense.is_invoiced ) {
			throw( type = "validation", message = "Cannot delete an expense that has been invoiced." );
		}

		queryExecute(
			"DELETE FROM expenses WHERE id = :id",
			{ id: { value: arguments.id, cfsqltype: "cf_sql_integer" } }
		);
	}

}
