<cfoutput>
<div class="container py-4">
	<div class="d-flex justify-content-between align-items-center mb-4">
		<h1><i class="bi bi-file-earmark-text"></i> #encodeForHTML( prc.contract.name )#</h1>
		<div class="d-flex gap-2">
			<a href="#event.buildLink( 'contracts' )#/#prc.contract.id#/edit" class="btn btn-outline-secondary">
				<i class="bi bi-pencil"></i> Edit
			</a>
			<form method="POST" action="#event.buildLink( 'contracts' )#/#prc.contract.id#"
				  class="d-inline"
				  onsubmit="return confirm( 'Are you sure you want to delete this contract?' );">
				<input type="hidden" name="_method" value="DELETE">
				<button type="submit" class="btn btn-outline-danger">
					<i class="bi bi-trash"></i> Delete
				</button>
			</form>
			<a href="#event.buildLink( 'contracts' )#" class="btn btn-outline-secondary">
				<i class="bi bi-arrow-left"></i> Back
			</a>
		</div>
	</div>

	<div class="row">
		<div class="col-md-6">
			<div class="card mb-4">
				<div class="card-header"><h5 class="mb-0">Contract Details</h5></div>
				<div class="card-body">
					<dl class="row mb-0">
						<dt class="col-sm-4">Client</dt>
						<dd class="col-sm-8">
							<a href="#event.buildLink( 'clients' )#/#prc.contract.client_id#">
								#encodeForHTML( prc.contract.client_name )#
							</a>
						</dd>

						<dt class="col-sm-4">Hourly Rate</dt>
						<dd class="col-sm-8">#formatCurrency( prc.contract.hourly_rate )#/hr</dd>

						<dt class="col-sm-4">Start Date</dt>
						<dd class="col-sm-8">#formatAppDate( prc.contract.start_date )#</dd>

						<dt class="col-sm-4">End Date</dt>
						<dd class="col-sm-8">
							<cfif isDate( prc.contract.end_date )>
								#formatAppDate( prc.contract.end_date )#
							<cfelse>
								<span class="text-muted">Ongoing</span>
							</cfif>
						</dd>

						<dt class="col-sm-4">Status</dt>
						<dd class="col-sm-8">#statusBadge( prc.contract.status )#</dd>

						<dt class="col-sm-4">Created</dt>
						<dd class="col-sm-8">#formatAppDate( prc.contract.created_at )#</dd>
					</dl>
				</div>
			</div>
		</div>

		<div class="col-md-6">
			<div class="card">
				<div class="card-header d-flex justify-content-between align-items-center">
					<h5 class="mb-0">Time Entries</h5>
					<a href="#event.buildLink( 'timeentries.new' )#?contract_id=#prc.contract.id#" class="btn btn-sm btn-primary">
						<i class="bi bi-plus-lg"></i> Log Time
					</a>
				</div>
				<div class="card-body">
					<cfif prc.timeEntries.recordCount>
						<cfset totalHours = 0>
						<cfloop query="prc.timeEntries">
							<cfset totalHours += prc.timeEntries.hours_worked>
						</cfloop>
						<div class="alert alert-info py-2 mb-3">
							<strong>#numberFormat( totalHours, '0.00' )# hours</strong> logged
							(#formatCurrency( totalHours * prc.contract.hourly_rate )# at #formatCurrency( prc.contract.hourly_rate )#/hr)
						</div>
						<table class="table table-sm mb-0">
							<thead>
								<tr>
									<th>Date</th>
									<th>Ticket</th>
									<th class="text-end">Hours</th>
								</tr>
							</thead>
							<tbody>
								<cfloop query="prc.timeEntries">
									<tr>
										<td>#formatAppDate( prc.timeEntries.entry_date )#</td>
										<td>
											<a href="#event.buildLink( 'tickets' )#/#prc.timeEntries.ticket_id#">
												#encodeForHTML( prc.timeEntries.ticket_title )#
											</a>
										</td>
										<td class="text-end">#numberFormat( prc.timeEntries.hours_worked, '0.00' )#</td>
									</tr>
								</cfloop>
							</tbody>
						</table>
					<cfelse>
						<p class="text-muted mb-0">No time entries logged yet.</p>
					</cfif>
				</div>
			</div>
		</div>
	</div>
</div>
</cfoutput>
