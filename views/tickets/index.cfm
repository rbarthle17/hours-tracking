<cfoutput>
<div class="container py-4">
	<div class="d-flex justify-content-between align-items-center mb-4">
		<h1><i class="bi bi-kanban"></i> Tickets</h1>
		<a href="#event.buildLink( 'tickets.new' )#" class="btn btn-primary">
			<i class="bi bi-plus-lg"></i> New Ticket
		</a>
	</div>

	<!--- Filters --->
	<form method="GET" action="#event.buildLink( 'tickets' )#" class="mb-3">
		<div class="row g-2" style="max-width: 800px;">
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
					<option value="open" #(rc.status ?: '') EQ 'open' ? 'selected' : ''#>Open</option>
					<option value="in_progress" #(rc.status ?: '') EQ 'in_progress' ? 'selected' : ''#>In Progress</option>
					<option value="done" #(rc.status ?: '') EQ 'done' ? 'selected' : ''#>Done</option>
					<option value="closed" #(rc.status ?: '') EQ 'closed' ? 'selected' : ''#>Closed</option>
				</select>
			</div>
			<div class="col-auto">
				<select name="priority" class="form-select form-select-sm">
					<option value="">All Priorities</option>
					<option value="high" #(rc.priority ?: '') EQ 'high' ? 'selected' : ''#>High</option>
					<option value="medium" #(rc.priority ?: '') EQ 'medium' ? 'selected' : ''#>Medium</option>
					<option value="low" #(rc.priority ?: '') EQ 'low' ? 'selected' : ''#>Low</option>
				</select>
			</div>
			<div class="col-auto">
				<button class="btn btn-sm btn-outline-secondary" type="submit">
					<i class="bi bi-funnel"></i> Filter
				</button>
				<cfif len( rc.client_id ?: "" ) OR len( rc.status ?: "" ) OR len( rc.priority ?: "" )>
					<a href="#event.buildLink( 'tickets' )#" class="btn btn-sm btn-outline-secondary">Clear</a>
				</cfif>
			</div>
		</div>
	</form>

	<div class="table-responsive">
		<table class="table table-striped table-hover">
			<thead class="table-dark">
				<tr>
					<th>Title</th>
					<th>Client</th>
					<th>Status</th>
					<th>Priority</th>
					<th>Created</th>
					<th class="text-end">Actions</th>
				</tr>
			</thead>
			<tbody>
				<cfif prc.tickets.recordCount>
					<cfloop query="prc.tickets">
						<tr>
							<td>
								<a href="#event.buildLink( 'tickets.show', { id: prc.tickets.id } )#">
									#encodeForHTML( prc.tickets.title )#
								</a>
							</td>
							<td>
								<a href="#event.buildLink( 'clients.show', { id: prc.tickets.client_id } )#">
									#encodeForHTML( prc.tickets.client_name )#
								</a>
							</td>
							<td>#statusBadge( prc.tickets.status )#</td>
							<td>#statusBadge( prc.tickets.priority )#</td>
							<td>#formatAppDate( prc.tickets.created_at )#</td>
							<td class="text-end">
								<a href="#event.buildLink( 'tickets.edit', { id: prc.tickets.id } )#"
								   class="btn btn-sm btn-outline-secondary">
									<i class="bi bi-pencil"></i>
								</a>
							</td>
						</tr>
					</cfloop>
				<cfelse>
					<tr>
						<td colspan="6" class="text-center text-muted py-4">No tickets found.</td>
					</tr>
				</cfif>
			</tbody>
		</table>
	</div>
</div>
</cfoutput>
