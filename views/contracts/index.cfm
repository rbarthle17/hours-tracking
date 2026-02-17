<cfoutput>
<div class="container py-4">
	<div class="d-flex justify-content-between align-items-center mb-4">
		<h1><i class="bi bi-file-earmark-text"></i> Contracts</h1>
		<a href="#event.buildLink( 'contracts.new' )#" class="btn btn-primary">
			<i class="bi bi-plus-lg"></i> New Contract
		</a>
	</div>

	<!--- Filters --->
	<form method="GET" action="#event.buildLink( 'contracts' )#" class="mb-3">
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
					<option value="active" #(rc.status ?: '') EQ 'active' ? 'selected' : ''#>Active</option>
					<option value="paused" #(rc.status ?: '') EQ 'paused' ? 'selected' : ''#>Paused</option>
					<option value="completed" #(rc.status ?: '') EQ 'completed' ? 'selected' : ''#>Completed</option>
				</select>
			</div>
			<div class="col-auto">
				<button class="btn btn-sm btn-outline-secondary" type="submit">
					<i class="bi bi-funnel"></i> Filter
				</button>
				<cfif len( rc.client_id ?: "" ) OR len( rc.status ?: "" )>
					<a href="#event.buildLink( 'contracts' )#" class="btn btn-sm btn-outline-secondary">Clear</a>
				</cfif>
			</div>
		</div>
	</form>

	<div class="table-responsive">
		<table class="table table-striped table-hover">
			<thead class="table-dark">
				<tr>
					<th>Name</th>
					<th>Client</th>
					<th>Rate</th>
					<th>Start Date</th>
					<th>End Date</th>
					<th>Status</th>
					<th class="text-end">Actions</th>
				</tr>
			</thead>
			<tbody>
				<cfif prc.contracts.recordCount>
					<cfloop query="prc.contracts">
						<tr>
							<td>
								<a href="#event.buildLink( 'contracts.show', { id: prc.contracts.id } )#">
									#encodeForHTML( prc.contracts.name )#
								</a>
							</td>
							<td>
								<a href="#event.buildLink( 'clients.show', { id: prc.contracts.client_id } )#">
									#encodeForHTML( prc.contracts.client_name )#
								</a>
							</td>
							<td>#formatCurrency( prc.contracts.hourly_rate )#/hr</td>
							<td>#formatAppDate( prc.contracts.start_date )#</td>
							<td>
								<cfif len( prc.contracts.end_date ) AND isDate( prc.contracts.end_date )>
									#formatAppDate( prc.contracts.end_date )#
								<cfelse>
									<span class="text-muted">Ongoing</span>
								</cfif>
							</td>
							<td>#statusBadge( prc.contracts.status )#</td>
							<td class="text-end">
								<a href="#event.buildLink( 'contracts.edit', { id: prc.contracts.id } )#"
								   class="btn btn-sm btn-outline-secondary">
									<i class="bi bi-pencil"></i>
								</a>
							</td>
						</tr>
					</cfloop>
				<cfelse>
					<tr>
						<td colspan="7" class="text-center text-muted py-4">No contracts found.</td>
					</tr>
				</cfif>
			</tbody>
		</table>
	</div>
</div>
</cfoutput>
