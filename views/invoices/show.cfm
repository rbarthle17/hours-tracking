<cfoutput>
<cfset balanceDue = prc.invoice.total_amount - prc.invoice.total_paid>

<div class="container py-4">
	<div class="d-flex justify-content-between align-items-center mb-4">
		<h1><i class="bi bi-receipt"></i> #encodeForHTML( prc.invoice.invoice_number )#</h1>
		<div class="d-flex gap-2">
			<cfif prc.invoice.status EQ "draft">
				<a href="#event.buildLink( 'invoices.edit', { id: prc.invoice.id } )#" class="btn btn-outline-secondary">
					<i class="bi bi-pencil"></i> Edit
				</a>
				<form method="POST" action="#event.buildLink( 'invoices' )#/#prc.invoice.id#/send" class="d-inline">
					<button type="submit" class="btn btn-success">
						<i class="bi bi-send"></i> Mark as Sent
					</button>
				</form>
				<form method="POST" action="#event.buildLink( 'invoices', { id: prc.invoice.id } )#"
					  class="d-inline"
					  onsubmit="return confirm( 'Are you sure you want to delete this invoice?' );">
					<input type="hidden" name="_method" value="DELETE">
					<button type="submit" class="btn btn-outline-danger">
						<i class="bi bi-trash"></i> Delete
					</button>
				</form>
			</cfif>
			<cfif listFindNoCase( "sent,partial,overdue", prc.invoice.status ) AND balanceDue GT 0>
				<a href="#event.buildLink( 'invoices' )#/#prc.invoice.id#/payments/new" class="btn btn-success">
					<i class="bi bi-cash"></i> Record Payment
				</a>
			</cfif>
			<a href="#event.buildLink( 'invoices' )#" class="btn btn-outline-secondary">
				<i class="bi bi-arrow-left"></i> Back
			</a>
		</div>
	</div>

	<div class="row">
		<!--- Invoice Header --->
		<div class="col-md-8">
			<div class="card mb-4">
				<div class="card-header d-flex justify-content-between align-items-center">
					<h5 class="mb-0">Invoice Details</h5>
					#statusBadge( prc.invoice.status )#
				</div>
				<div class="card-body">
					<div class="row mb-3">
						<div class="col-md-6">
							<dl class="row mb-0">
								<dt class="col-sm-5">Client</dt>
								<dd class="col-sm-7">
									<a href="#event.buildLink( 'clients.show', { id: prc.invoice.client_id } )#">
										#encodeForHTML( prc.invoice.client_name )#
									</a>
								</dd>
								<dt class="col-sm-5">Invoice Date</dt>
								<dd class="col-sm-7">#formatAppDate( prc.invoice.invoice_date )#</dd>
								<dt class="col-sm-5">Due Date</dt>
								<dd class="col-sm-7">#formatAppDate( prc.invoice.due_date )#</dd>
							</dl>
						</div>
						<div class="col-md-6">
							<dl class="row mb-0">
								<dt class="col-sm-5">Total</dt>
								<dd class="col-sm-7"><strong>#formatCurrency( prc.invoice.total_amount )#</strong></dd>
								<dt class="col-sm-5">Paid</dt>
								<dd class="col-sm-7">#formatCurrency( prc.invoice.total_paid )#</dd>
								<dt class="col-sm-5">Balance Due</dt>
								<dd class="col-sm-7">
									<cfif balanceDue GT 0>
										<strong class="text-danger">#formatCurrency( balanceDue )#</strong>
									<cfelse>
										<strong class="text-success">#formatCurrency( 0 )#</strong>
									</cfif>
								</dd>
							</dl>
						</div>
					</div>

					<cfif len( prc.invoice.notes ?: '' )>
						<hr>
						<p class="mb-0"><strong>Notes:</strong> #encodeForHTML( prc.invoice.notes )#</p>
					</cfif>
				</div>
			</div>

			<!--- Line Items --->
			<div class="card mb-4">
				<div class="card-header"><h5 class="mb-0">Line Items</h5></div>
				<div class="card-body p-0">
					<table class="table mb-0">
						<thead class="table-light">
							<tr>
								<th>Description</th>
								<th>Contract</th>
								<th class="text-end">Hours</th>
								<th class="text-end">Rate</th>
								<th class="text-end">Subtotal</th>
							</tr>
						</thead>
						<tbody>
							<cfloop query="prc.lineItems">
								<tr>
									<td>#encodeForHTML( prc.lineItems.description )#</td>
									<td>#encodeForHTML( prc.lineItems.contract_name )#</td>
									<td class="text-end">#numberFormat( prc.lineItems.hours, '0.00' )#</td>
									<td class="text-end">#formatCurrency( prc.lineItems.rate )#</td>
									<td class="text-end">#formatCurrency( prc.lineItems.subtotal )#</td>
								</tr>
							</cfloop>
						</tbody>
						<tfoot class="table-light">
							<tr>
								<th colspan="4" class="text-end">Total</th>
								<th class="text-end">#formatCurrency( prc.invoice.total_amount )#</th>
							</tr>
						</tfoot>
					</table>
				</div>
			</div>
		</div>

		<!--- Payments Sidebar --->
		<div class="col-md-4">
			<div class="card">
				<div class="card-header d-flex justify-content-between align-items-center">
					<h5 class="mb-0">Payments</h5>
					<cfif listFindNoCase( "sent,partial,overdue", prc.invoice.status ) AND balanceDue GT 0>
						<a href="#event.buildLink( 'invoices' )#/#prc.invoice.id#/payments/new" class="btn btn-sm btn-primary">
							<i class="bi bi-plus-lg"></i> Add
						</a>
					</cfif>
				</div>
				<div class="card-body">
					<cfif prc.payments.recordCount>
						<cfloop query="prc.payments">
							<div class="d-flex justify-content-between align-items-start mb-3 pb-3 border-bottom">
								<div>
									<strong>#formatCurrency( prc.payments.amount )#</strong><br>
									<small class="text-muted">
										#formatAppDate( prc.payments.payment_date )#
										<cfif len( prc.payments.method ?: '' )> &middot; #encodeForHTML( prc.payments.method )#</cfif>
									</small>
									<cfif len( prc.payments.reference_number ?: '' )>
										<br><small class="text-muted">Ref: #encodeForHTML( prc.payments.reference_number )#</small>
									</cfif>
								</div>
								<form method="POST" action="#event.buildLink( 'invoices' )#/#prc.invoice.id#/payments/#prc.payments.id#"
									  class="d-inline"
									  onsubmit="return confirm( 'Delete this payment?' );">
									<input type="hidden" name="_method" value="DELETE">
									<button type="submit" class="btn btn-sm btn-outline-danger">
										<i class="bi bi-trash"></i>
									</button>
								</form>
							</div>
						</cfloop>
					<cfelse>
						<p class="text-muted mb-0">No payments recorded yet.</p>
					</cfif>
				</div>
			</div>
		</div>
	</div>
</div>
</cfoutput>
