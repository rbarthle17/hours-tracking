<cfoutput>
<div class="container py-4">
	<div class="d-flex justify-content-between align-items-center mb-4">
		<h1><i class="bi bi-receipt"></i> Invoices</h1>
		<a href="#event.buildLink( 'invoices.new' )#" class="btn btn-primary">
			<i class="bi bi-plus-lg"></i> New Invoice
		</a>
	</div>

	<!--- Filters --->
	<form method="GET" action="#event.buildLink( 'invoices' )#" class="mb-3">
		<div class="row g-2" style="max-width: 600px;">
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
				<select name="status" class="form-select form-select-sm">
					<option value="">All Statuses</option>
					<option value="draft" #(rc.status ?: '') EQ 'draft' ? 'selected' : ''#>Draft</option>
					<option value="sent" #(rc.status ?: '') EQ 'sent' ? 'selected' : ''#>Sent</option>
					<option value="paid" #(rc.status ?: '') EQ 'paid' ? 'selected' : ''#>Paid</option>
					<option value="partial" #(rc.status ?: '') EQ 'partial' ? 'selected' : ''#>Partial</option>
					<option value="overdue" #(rc.status ?: '') EQ 'overdue' ? 'selected' : ''#>Overdue</option>
				</select>
			</div>
			<div class="col-auto">
				<button class="btn btn-sm btn-outline-secondary" type="submit">
					<i class="bi bi-funnel"></i> Filter
				</button>
				<cfif len( rc.client_id ?: "" ) OR len( rc.status ?: "" )>
					<a href="#event.buildLink( 'invoices' )#" class="btn btn-sm btn-outline-secondary">Clear</a>
				</cfif>
			</div>
		</div>
	</form>

	<div class="table-responsive">
		<table class="table table-striped table-hover">
			<thead class="table-dark">
				<tr>
					<th>Invoice ##</th>
					<th>Client</th>
					<th>Date</th>
					<th>Due Date</th>
					<th class="text-end">Amount</th>
					<th class="text-end">Balance Due</th>
					<th>Status</th>
					<th class="text-end">Actions</th>
				</tr>
			</thead>
			<tbody>
				<cfif prc.invoices.recordCount>
					<cfloop query="prc.invoices">
						<tr>
							<td>
								<a href="#event.buildLink( 'invoices' )#/#prc.invoices.id#">
									#encodeForHTML( prc.invoices.invoice_number )#
								</a>
							</td>
							<td>
								<a href="#event.buildLink( 'clients' )#/#prc.invoices.client_id#">
									#encodeForHTML( prc.invoices.client_name )#
								</a>
							</td>
							<td>#formatAppDate( prc.invoices.invoice_date )#</td>
							<td>#formatAppDate( prc.invoices.due_date )#</td>
							<td class="text-end">#formatCurrency( prc.invoices.total_amount )#</td>
							<td class="text-end">
								<cfset balanceDue = prc.invoices.total_amount - prc.invoices.total_paid>
								<cfif balanceDue GT 0>
									<strong class="text-danger">#formatCurrency( balanceDue )#</strong>
								<cfelse>
									<span class="text-success">#formatCurrency( 0 )#</span>
								</cfif>
							</td>
							<td>#statusBadge( prc.invoices.status )#</td>
							<td class="text-end">
								<a href="#event.buildLink( 'invoices' )#/#prc.invoices.id#"
								   class="btn btn-sm btn-outline-secondary">
									<i class="bi bi-eye"></i>
								</a>
							</td>
						</tr>
					</cfloop>
				<cfelse>
					<tr>
						<td colspan="8" class="text-center text-muted py-4">No invoices found.</td>
					</tr>
				</cfif>
			</tbody>
		</table>
	</div>
</div>
</cfoutput>
