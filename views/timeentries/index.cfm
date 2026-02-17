<cfoutput>
<div class="container py-4">
	<div class="d-flex justify-content-between align-items-center mb-4">
		<h1><i class="bi bi-clock-history"></i> Time Entries</h1>
		<a href="#event.buildLink( 'timeentries.new' )#" class="btn btn-primary">
			<i class="bi bi-plus-lg"></i> Log Time
		</a>
	</div>

	<!--- Filters --->
	<form method="GET" action="#event.buildLink( 'timeentries' )#" class="mb-3">
		<div class="row g-2" style="max-width: 900px;">
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
				<select name="contract_id" class="form-select form-select-sm">
					<option value="">All Contracts</option>
					<cfloop query="prc.contracts">
						<option value="#prc.contracts.id#" #val( rc.contract_id ?: 0 ) EQ prc.contracts.id ? 'selected' : ''#>
							#encodeForHTML( prc.contracts.client_name )# - #encodeForHTML( prc.contracts.name )#
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
				<button class="btn btn-sm btn-outline-secondary" type="submit">
					<i class="bi bi-funnel"></i> Filter
				</button>
				<cfif len( rc.client_id ?: "" ) OR len( rc.contract_id ?: "" ) OR len( rc.start_date ?: "" ) OR len( rc.end_date ?: "" )>
					<a href="#event.buildLink( 'timeentries' )#" class="btn btn-sm btn-outline-secondary">Clear</a>
				</cfif>
			</div>
		</div>
	</form>

	<!--- Summary --->
	<cfif prc.timeEntries.recordCount>
		<cfset totalHours = 0>
		<cfloop query="prc.timeEntries">
			<cfset totalHours += prc.timeEntries.hours_worked>
		</cfloop>
		<div class="alert alert-info py-2 mb-3" style="max-width: 400px;">
			<strong>#numberFormat( totalHours, '0.00' )# hours</strong> across #prc.timeEntries.recordCount# entries
		</div>
	</cfif>

	<div class="table-responsive">
		<table class="table table-striped table-hover">
			<thead class="table-dark">
				<tr>
					<th>Date</th>
					<th>Ticket</th>
					<th>Client</th>
					<th>Contract</th>
					<th class="text-end">Hours</th>
					<th>Notes</th>
					<th class="text-end">Actions</th>
				</tr>
			</thead>
			<tbody>
				<cfif prc.timeEntries.recordCount>
					<cfloop query="prc.timeEntries">
						<tr>
							<td>#formatAppDate( prc.timeEntries.entry_date )#</td>
							<td>
								<a href="#event.buildLink( 'tickets.show', { id: prc.timeEntries.ticket_id } )#">
									#encodeForHTML( prc.timeEntries.ticket_title )#
								</a>
							</td>
							<td>
								<a href="#event.buildLink( 'clients.show', { id: prc.timeEntries.client_id } )#">
									#encodeForHTML( prc.timeEntries.client_name )#
								</a>
							</td>
							<td>#encodeForHTML( prc.timeEntries.contract_name )#</td>
							<td class="text-end">#numberFormat( prc.timeEntries.hours_worked, '0.00' )#</td>
							<td>
								<cfif len( prc.timeEntries.notes ?: '' )>
									<span title="#encodeForHTMLAttribute( prc.timeEntries.notes )#">
										#encodeForHTML( left( prc.timeEntries.notes, 40 ) )#<cfif len( prc.timeEntries.notes ) GT 40>...</cfif>
									</span>
								</cfif>
							</td>
							<td class="text-end">
								<a href="#event.buildLink( 'timeentries.edit', { id: prc.timeEntries.id } )#"
								   class="btn btn-sm btn-outline-secondary">
									<i class="bi bi-pencil"></i>
								</a>
							</td>
						</tr>
					</cfloop>
				<cfelse>
					<tr>
						<td colspan="7" class="text-center text-muted py-4">No time entries found.</td>
					</tr>
				</cfif>
			</tbody>
		</table>
	</div>
</div>
</cfoutput>
