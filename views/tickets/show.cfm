<cfoutput>
<div class="container py-4">
	<div class="d-flex justify-content-between align-items-center mb-4">
		<h1><i class="bi bi-kanban"></i> #encodeForHTML( prc.ticket.title )#</h1>
		<div class="d-flex gap-2">
			<a href="#event.buildLink( 'tickets.edit', { id: prc.ticket.id } )#" class="btn btn-outline-secondary">
				<i class="bi bi-pencil"></i> Edit
			</a>
			<form method="POST" action="#event.buildLink( 'tickets', { id: prc.ticket.id } )#"
				  class="d-inline"
				  onsubmit="return confirm( 'Are you sure you want to delete this ticket?' );">
				<input type="hidden" name="_method" value="DELETE">
				<button type="submit" class="btn btn-outline-danger">
					<i class="bi bi-trash"></i> Delete
				</button>
			</form>
			<a href="#event.buildLink( 'tickets' )#" class="btn btn-outline-secondary">
				<i class="bi bi-arrow-left"></i> Back
			</a>
		</div>
	</div>

	<div class="row">
		<div class="col-md-6">
			<div class="card mb-4">
				<div class="card-header"><h5 class="mb-0">Ticket Details</h5></div>
				<div class="card-body">
					<dl class="row mb-0">
						<dt class="col-sm-4">Client</dt>
						<dd class="col-sm-8">
							<a href="#event.buildLink( 'clients.show', { id: prc.ticket.client_id } )#">
								#encodeForHTML( prc.ticket.client_name )#
							</a>
						</dd>

						<dt class="col-sm-4">Status</dt>
						<dd class="col-sm-8">#statusBadge( prc.ticket.status )#</dd>

						<dt class="col-sm-4">Priority</dt>
						<dd class="col-sm-8">#statusBadge( prc.ticket.priority )#</dd>

						<dt class="col-sm-4">Created</dt>
						<dd class="col-sm-8">#formatAppDate( prc.ticket.created_at )#</dd>

						<cfif len( prc.ticket.description ?: '' )>
							<dt class="col-sm-4">Description</dt>
							<dd class="col-sm-8">
								#replace( encodeForHTML( prc.ticket.description ), chr(10), "<br>", "all" )#
							</dd>
						</cfif>
					</dl>
				</div>
			</div>
		</div>

		<div class="col-md-6">
			<div class="card">
				<div class="card-header d-flex justify-content-between align-items-center">
					<h5 class="mb-0">Time Entries</h5>
					<a href="#event.buildLink( 'timeentries.new' )#?ticket_id=#prc.ticket.id#" class="btn btn-sm btn-primary">
						<i class="bi bi-plus-lg"></i> Log Time
					</a>
				</div>
				<div class="card-body">
					<cfif prc.timeEntries.recordCount>
						<table class="table table-sm mb-0">
							<thead>
								<tr>
									<th>Date</th>
									<th>Contract</th>
									<th class="text-end">Hours</th>
								</tr>
							</thead>
							<tbody>
								<cfloop query="prc.timeEntries">
									<tr>
										<td>#formatAppDate( prc.timeEntries.entry_date )#</td>
										<td>#encodeForHTML( prc.timeEntries.contract_name )#</td>
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
