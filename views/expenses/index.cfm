<cfoutput>
<div class="container py-4">
	<div class="d-flex justify-content-between align-items-center mb-4">
		<h1><i class="bi bi-receipt-cutoff"></i> Expenses</h1>
		<a href="#event.buildLink( 'expenses.new' )#" class="btn btn-primary">
			<i class="bi bi-plus-lg"></i> New Expense
		</a>
	</div>

	<!--- Filters --->
	<form method="GET" action="#event.buildLink( 'expenses' )#" class="mb-3">
		<div class="row g-2" style="max-width: 1000px;">
			<div class="col-auto">
				<select name="client_id" class="form-select form-select-sm">
					<option value="">All Clients</option>
					<cfloop query="prc.clients">
						<option value="#prc.clients.id#" #val( rc.client_id ?: 0 ) EQ prc.clients.id ? 'selected' : ''#>
							#encodeForHTML( prc.clients.name )#
						</option>
					</cfloop>
				</select>
			</div>
			<div class="col-auto">
				<select name="category" class="form-select form-select-sm">
					<option value="">All Categories</option>
					<cfloop array="#prc.categories#" item="cat">
						<option value="#encodeForHTMLAttribute( cat )#" #( rc.category ?: '' ) EQ cat ? 'selected' : ''#>
							#encodeForHTML( cat )#
						</option>
					</cfloop>
				</select>
			</div>
			<div class="col-auto">
				<input type="date" name="start_date" class="form-control form-control-sm"
					   value="#encodeForHTMLAttribute( rc.start_date ?: '' )#" placeholder="From">
			</div>
			<div class="col-auto">
				<input type="date" name="end_date" class="form-control form-control-sm"
					   value="#encodeForHTMLAttribute( rc.end_date ?: '' )#" placeholder="To">
			</div>
			<div class="col-auto">
				<div class="form-check form-check-inline mt-1">
					<input class="form-check-input" type="checkbox" id="billable_filter" name="billable"
						   value="1" #( rc.billable ?: '' ) EQ '1' ? 'checked' : ''#>
					<label class="form-check-label" for="billable_filter">Billable only</label>
				</div>
			</div>
			<div class="col-auto">
				<button class="btn btn-sm btn-outline-secondary" type="submit">
					<i class="bi bi-funnel"></i> Filter
				</button>
				<cfif len( rc.client_id ?: "" ) OR len( rc.category ?: "" ) OR len( rc.start_date ?: "" ) OR len( rc.end_date ?: "" ) OR len( rc.billable ?: "" )>
					<a href="#event.buildLink( 'expenses' )#" class="btn btn-sm btn-outline-secondary">Clear</a>
				</cfif>
			</div>
		</div>
	</form>

	<!--- Export links --->
	<cfset exportParams = "">
	<cfif val( rc.client_id ?: 0 )><cfset exportParams &= "&client_id=#encodeForURL( rc.client_id )#"></cfif>
	<cfif len( rc.category ?: "" )><cfset exportParams &= "&category=#encodeForURL( rc.category )#"></cfif>
	<cfif len( rc.start_date ?: "" )><cfset exportParams &= "&start_date=#encodeForURL( rc.start_date )#"></cfif>
	<cfif len( rc.end_date ?: "" )><cfset exportParams &= "&end_date=#encodeForURL( rc.end_date )#"></cfif>
	<cfif len( rc.billable ?: "" )><cfset exportParams &= "&billable=#encodeForURL( rc.billable )#"></cfif>
	<div class="mb-3 d-flex gap-2">
		<a href="#event.buildLink( 'expenses/export' )##len( exportParams ) ? '?' & mid( exportParams, 2, len( exportParams ) ) : ''#"
		   class="btn btn-sm btn-outline-secondary">
			<i class="bi bi-download"></i> Export CSV
		</a>
		<a href="#event.buildLink( 'expenses/pnl' )#" class="btn btn-sm btn-outline-secondary">
			<i class="bi bi-graph-up"></i> P&amp;L Export
		</a>
	</div>

	<!--- Summary --->
	<cfif prc.expenses.recordCount>
		<cfset totalAmount = 0>
		<cfloop query="prc.expenses">
			<cfset totalAmount += prc.expenses.amount>
		</cfloop>
		<div class="alert alert-info py-2 mb-3" style="max-width: 400px;">
			<strong>#formatCurrency( totalAmount )#</strong> across #prc.expenses.recordCount# expense<cfif prc.expenses.recordCount NEQ 1>s</cfif>
		</div>
	</cfif>

	<div class="table-responsive">
		<table class="table table-striped table-hover">
			<thead class="table-dark">
				<tr>
					<th>Date</th>
					<th>Vendor</th>
					<th>Category</th>
					<th>Client</th>
					<th class="text-end">Amount</th>
					<th>Billable</th>
					<th class="text-end">Actions</th>
				</tr>
			</thead>
			<tbody>
				<cfif prc.expenses.recordCount>
					<cfloop query="prc.expenses">
						<tr>
							<td>#formatAppDate( prc.expenses.expense_date )#</td>
							<td>
								<a href="#event.buildLink( 'expenses' )#/#prc.expenses.id#">
									#encodeForHTML( prc.expenses.vendor )#
								</a>
							</td>
							<td>#encodeForHTML( prc.expenses.category )#</td>
							<td>
								<cfif len( prc.expenses.client_name ?: '' )>
									#encodeForHTML( prc.expenses.client_name )#
								<cfelse>
									<span class="text-muted">General</span>
								</cfif>
							</td>
							<td class="text-end">#formatCurrency( prc.expenses.amount )#</td>
							<td>
								<cfif prc.expenses.is_billable>
									<cfif prc.expenses.is_invoiced>
										<span class="badge bg-secondary">Invoiced</span>
									<cfelse>
										<span class="badge bg-warning text-dark">Billable</span>
									</cfif>
								</cfif>
							</td>
							<td class="text-end">
								<a href="#event.buildLink( 'expenses' )#/#prc.expenses.id#/edit"
								   class="btn btn-sm btn-outline-secondary">
									<i class="bi bi-pencil"></i>
								</a>
							</td>
						</tr>
					</cfloop>
				<cfelse>
					<tr>
						<td colspan="7" class="text-center text-muted py-4">No expenses found.</td>
					</tr>
				</cfif>
			</tbody>
			<cfif prc.expenses.recordCount>
				<tfoot class="table-light">
					<tr>
						<td colspan="4" class="text-end fw-bold">Total</td>
						<td class="text-end fw-bold">#formatCurrency( totalAmount )#</td>
						<td colspan="2"></td>
					</tr>
				</tfoot>
			</cfif>
		</table>
	</div>
</div>
</cfoutput>
