<cfoutput>
<div class="container py-4">
	<h1 class="mb-4"><i class="bi bi-speedometer2"></i> Dashboard</h1>

	<!--- Stat Cards --->
	<div class="row g-3 mb-4">
		<div class="col-md-3">
			<div class="card text-center">
				<div class="card-body">
					<div class="text-muted small">Active Contracts</div>
					<div class="display-6 fw-bold">#prc.activeContracts.cnt#</div>
				</div>
			</div>
		</div>
		<div class="col-md-3">
			<div class="card text-center">
				<div class="card-body">
					<div class="text-muted small">Hours This Month</div>
					<div class="display-6 fw-bold">#numberFormat( prc.hoursThisMonth.total_hours, '0.0' )#</div>
				</div>
			</div>
		</div>
		<div class="col-md-3">
			<div class="card text-center">
				<div class="card-body">
					<div class="text-muted small">Outstanding Balance</div>
					<div class="display-6 fw-bold text-danger">#formatCurrency( prc.outstandingBalance.balance )#</div>
				</div>
			</div>
		</div>
		<div class="col-md-3">
			<div class="card text-center">
				<div class="card-body">
					<div class="text-muted small">Revenue This Month</div>
					<div class="display-6 fw-bold text-success">#formatCurrency( prc.monthlyRevenue.revenue )#</div>
				</div>
			</div>
		</div>
	</div>

	<div class="row g-4">
		<!--- Recent Time Entries --->
		<div class="col-md-7">
			<div class="card">
				<div class="card-header d-flex justify-content-between align-items-center">
					<h5 class="mb-0">Recent Time Entries</h5>
					<a href="#event.buildLink( 'timeentries.new' )#" class="btn btn-sm btn-primary">
						<i class="bi bi-plus-lg"></i> Log Time
					</a>
				</div>
				<div class="card-body p-0">
					<cfif prc.recentEntries.recordCount>
						<table class="table table-hover mb-0">
							<thead class="table-light">
								<tr>
									<th>Date</th>
									<th>Ticket</th>
									<th>Client</th>
									<th class="text-end">Hours</th>
									<th class="text-end">Amount</th>
								</tr>
							</thead>
							<tbody>
								<cfloop query="prc.recentEntries">
									<tr>
										<td>#formatAppDate( prc.recentEntries.entry_date )#</td>
										<td>
											<a href="#event.buildLink( 'tickets' )#/#prc.recentEntries.ticket_id#">
												#encodeForHTML( prc.recentEntries.ticket_title )#
											</a>
										</td>
										<td>#encodeForHTML( prc.recentEntries.client_name )#</td>
										<td class="text-end">#numberFormat( prc.recentEntries.hours_worked, '0.00' )#</td>
										<td class="text-end">#formatCurrency( prc.recentEntries.hours_worked * prc.recentEntries.hourly_rate )#</td>
									</tr>
								</cfloop>
							</tbody>
						</table>
					<cfelse>
						<p class="text-muted text-center py-4 mb-0">No time entries yet. <a href="#event.buildLink( 'timeentries.new' )#">Log your first entry</a>.</p>
					</cfif>
				</div>
				<cfif prc.recentEntries.recordCount>
					<div class="card-footer text-end">
						<a href="#event.buildLink( 'timeentries' )#" class="btn btn-sm btn-outline-secondary">View All</a>
					</div>
				</cfif>
			</div>
		</div>

		<!--- Outstanding Invoices --->
		<div class="col-md-5">
			<div class="card">
				<div class="card-header d-flex justify-content-between align-items-center">
					<h5 class="mb-0">Outstanding Invoices</h5>
					<a href="#event.buildLink( 'invoices.new' )#" class="btn btn-sm btn-primary">
						<i class="bi bi-plus-lg"></i> New Invoice
					</a>
				</div>
				<div class="card-body p-0">
					<cfif prc.outstandingInvoices.recordCount>
						<table class="table table-hover mb-0">
							<thead class="table-light">
								<tr>
									<th>Invoice</th>
									<th>Client</th>
									<th class="text-end">Balance</th>
									<th>Due</th>
								</tr>
							</thead>
							<tbody>
								<cfloop query="prc.outstandingInvoices">
									<cfset balance = prc.outstandingInvoices.total_amount - prc.outstandingInvoices.total_paid>
									<tr>
										<td>
											<a href="#event.buildLink( 'invoices' )#/#prc.outstandingInvoices.id#">
												#encodeForHTML( prc.outstandingInvoices.invoice_number )#
											</a>
										</td>
										<td>#encodeForHTML( prc.outstandingInvoices.client_name )#</td>
										<td class="text-end text-danger"><strong>#formatCurrency( balance )#</strong></td>
										<td>
											<cfif isDate( prc.outstandingInvoices.due_date ) AND prc.outstandingInvoices.due_date LT now()>
												<span class="text-danger">#formatAppDate( prc.outstandingInvoices.due_date )#</span>
											<cfelse>
												#formatAppDate( prc.outstandingInvoices.due_date )#
											</cfif>
										</td>
									</tr>
								</cfloop>
							</tbody>
						</table>
					<cfelse>
						<p class="text-muted text-center py-4 mb-0">No outstanding invoices. All caught up!</p>
					</cfif>
				</div>
				<cfif prc.outstandingInvoices.recordCount>
					<div class="card-footer text-end">
						<a href="#event.buildLink( 'invoices' )#" class="btn btn-sm btn-outline-secondary">View All</a>
					</div>
				</cfif>
			</div>
		</div>
	</div>
</div>
</cfoutput>
