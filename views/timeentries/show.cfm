<cfoutput>
<div class="container py-4">
	<div class="d-flex justify-content-between align-items-center mb-4">
		<h1><i class="bi bi-clock-history"></i> Time Entry</h1>
		<div class="d-flex gap-2">
			<a href="#event.buildLink( 'timeentries.edit', { id: prc.timeEntry.id } )#" class="btn btn-outline-secondary">
				<i class="bi bi-pencil"></i> Edit
			</a>
			<form method="POST" action="#event.buildLink( 'timeentries', { id: prc.timeEntry.id } )#"
				  class="d-inline"
				  onsubmit="return confirm( 'Are you sure you want to delete this time entry?' );">
				<input type="hidden" name="_method" value="DELETE">
				<button type="submit" class="btn btn-outline-danger">
					<i class="bi bi-trash"></i> Delete
				</button>
			</form>
			<a href="#event.buildLink( 'timeentries' )#" class="btn btn-outline-secondary">
				<i class="bi bi-arrow-left"></i> Back
			</a>
		</div>
	</div>

	<div class="row">
		<div class="col-md-6">
			<div class="card">
				<div class="card-header"><h5 class="mb-0">Entry Details</h5></div>
				<div class="card-body">
					<dl class="row mb-0">
						<dt class="col-sm-4">Date</dt>
						<dd class="col-sm-8">#formatAppDate( prc.timeEntry.entry_date )#</dd>

						<dt class="col-sm-4">Hours</dt>
						<dd class="col-sm-8"><strong>#numberFormat( prc.timeEntry.hours_worked, '0.00' )#</strong></dd>

						<dt class="col-sm-4">Ticket</dt>
						<dd class="col-sm-8">
							<a href="#event.buildLink( 'tickets.show', { id: prc.timeEntry.ticket_id } )#">
								#encodeForHTML( prc.timeEntry.ticket_title )#
							</a>
						</dd>

						<dt class="col-sm-4">Client</dt>
						<dd class="col-sm-8">
							<a href="#event.buildLink( 'clients.show', { id: prc.timeEntry.client_id } )#">
								#encodeForHTML( prc.timeEntry.client_name )#
							</a>
						</dd>

						<dt class="col-sm-4">Contract</dt>
						<dd class="col-sm-8">
							<a href="#event.buildLink( 'contracts.show', { id: prc.timeEntry.contract_id } )#">
								#encodeForHTML( prc.timeEntry.contract_name )#
							</a>
						</dd>

						<dt class="col-sm-4">Rate</dt>
						<dd class="col-sm-8">#formatCurrency( prc.timeEntry.hourly_rate )#/hr</dd>

						<dt class="col-sm-4">Amount</dt>
						<dd class="col-sm-8">
							<strong>#formatCurrency( prc.timeEntry.hours_worked * prc.timeEntry.hourly_rate )#</strong>
						</dd>

						<dt class="col-sm-4">Logged by</dt>
						<dd class="col-sm-8">#encodeForHTML( prc.timeEntry.user_name )#</dd>

						<cfif len( prc.timeEntry.notes ?: '' )>
							<dt class="col-sm-4">Notes</dt>
							<dd class="col-sm-8">
								#replace( encodeForHTML( prc.timeEntry.notes ), chr(10), "<br>", "all" )#
							</dd>
						</cfif>
					</dl>
				</div>
			</div>
		</div>
	</div>
</div>
</cfoutput>
