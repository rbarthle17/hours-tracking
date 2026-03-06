<cfoutput>
<div class="container py-4">
	<div class="d-flex justify-content-between align-items-center mb-4">
		<h1><i class="bi bi-receipt-cutoff"></i> #encodeForHTML( prc.expense.vendor )#</h1>
		<div class="d-flex gap-2">
			<a href="#event.buildLink( 'expenses' )#/#prc.expense.id#/edit"
			   class="btn btn-outline-secondary">
				<i class="bi bi-pencil"></i> Edit
			</a>
			<form method="POST" action="#event.buildLink( 'expenses' )#/#prc.expense.id#"
				  class="d-inline"
				  onsubmit="return confirm( 'Are you sure you want to delete this expense?' );">
				<input type="hidden" name="_method" value="DELETE">
				<button type="submit" class="btn btn-outline-danger">
					<i class="bi bi-trash"></i> Delete
				</button>
			</form>
			<a href="#event.buildLink( 'expenses' )#" class="btn btn-outline-secondary">
				<i class="bi bi-arrow-left"></i> Back to Expenses
			</a>
		</div>
	</div>

	<!--- Unbilled billable expense warning --->
	<cfif prc.expense.is_billable AND NOT prc.expense.is_invoiced>
		<div class="alert alert-warning mb-4">
			<i class="bi bi-exclamation-triangle"></i>
			This expense is marked as billable but has not yet been added to an invoice.
		</div>
	</cfif>

	<div class="row">
		<div class="col-md-6">
			<div class="card mb-4">
				<div class="card-header"><h5 class="mb-0">Expense Details</h5></div>
				<div class="card-body">
					<dl class="row mb-0">
						<dt class="col-sm-4">Date</dt>
						<dd class="col-sm-8">#formatAppDate( prc.expense.expense_date )#</dd>

						<dt class="col-sm-4">Vendor / Payee</dt>
						<dd class="col-sm-8">#encodeForHTML( prc.expense.vendor )#</dd>

						<dt class="col-sm-4">Amount</dt>
						<dd class="col-sm-8"><strong>#formatCurrency( prc.expense.amount )#</strong></dd>

						<dt class="col-sm-4">Category</dt>
						<dd class="col-sm-8">#encodeForHTML( prc.expense.category )#</dd>

						<dt class="col-sm-4">Billable</dt>
						<dd class="col-sm-8">
							<cfif prc.expense.is_billable>
								<cfif prc.expense.is_invoiced>
									<span class="badge bg-secondary">Invoiced</span>
								<cfelse>
									<span class="badge bg-warning text-dark">Billable — Not Yet Invoiced</span>
								</cfif>
							<cfelse>
								<span class="text-muted">No</span>
							</cfif>
						</dd>

						<cfif len( prc.expense.receipt_reference ?: '' )>
							<dt class="col-sm-4">Receipt Ref.</dt>
							<dd class="col-sm-8">#encodeForHTML( prc.expense.receipt_reference )#</dd>
						</cfif>

						<cfif len( prc.expense.description ?: '' )>
							<dt class="col-sm-4">Description</dt>
							<dd class="col-sm-8">#encodeForHTML( prc.expense.description )#</dd>
						</cfif>

						<dt class="col-sm-4">Added</dt>
						<dd class="col-sm-8 text-muted">#formatAppDate( prc.expense.created_at )#</dd>
					</dl>
				</div>
			</div>
		</div>

		<div class="col-md-6">
			<div class="card mb-4">
				<div class="card-header"><h5 class="mb-0">Client</h5></div>
				<div class="card-body">
					<cfif len( prc.expense.client_name ?: '' )>
						<p class="mb-0">
							<a href="#event.buildLink( 'clients' )#/#prc.expense.client_id#">
								#encodeForHTML( prc.expense.client_name )#
							</a>
						</p>
						<cfif prc.expense.is_billable>
							<p class="text-muted small mt-1 mb-0">
								This expense will appear in the unbilled expenses list when creating an invoice for this client.
							</p>
						</cfif>
					<cfelse>
						<p class="text-muted mb-0">
							<i class="bi bi-briefcase"></i> General business expense — not linked to a specific client.
						</p>
					</cfif>
				</div>
			</div>
		</div>
	</div>
</div>
</cfoutput>
