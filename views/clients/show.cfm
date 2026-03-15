<cfoutput>
<div class="container py-4">
	<div class="d-flex justify-content-between align-items-center mb-4">
		<h1><i class="bi bi-person"></i> #encodeForHTML( prc.client.name )#</h1>
		<div class="d-flex gap-2">
			<a href="#event.buildLink( 'clients' )#/#prc.client.id#/edit" class="btn btn-outline-secondary">
				<i class="bi bi-pencil"></i> Edit
			</a>
			<form method="POST" action="#event.buildLink( 'clients' )#/#prc.client.id#"
				  class="d-inline"
				  onsubmit="return confirm( 'Are you sure you want to delete this client?' );">
				<input type="hidden" name="_method" value="DELETE">
				<button type="submit" class="btn btn-outline-danger">
					<i class="bi bi-trash"></i> Delete
				</button>
			</form>
			<a href="#event.buildLink( 'clients' )#" class="btn btn-outline-secondary">
				<i class="bi bi-arrow-left"></i> Back to Clients
			</a>
		</div>
	</div>

	<div class="row">
		<div class="col-md-6">
			<div class="card mb-4">
				<div class="card-header"><h5 class="mb-0">Client Details</h5></div>
				<div class="card-body">
					<dl class="row mb-0">
						<dt class="col-sm-3">Email</dt>
						<dd class="col-sm-9">
							<cfif len( prc.client.email )>
								<a href="mailto:#encodeForHTMLAttribute( prc.client.email )#">#encodeForHTML( prc.client.email )#</a>
							<cfelse>
								<span class="text-muted">Not provided</span>
							</cfif>
						</dd>

						<dt class="col-sm-3">Phone</dt>
						<dd class="col-sm-9">
							<cfif len( prc.client.phone )>
								#encodeForHTML( prc.client.phone )#
							<cfelse>
								<span class="text-muted">Not provided</span>
							</cfif>
						</dd>

						<dt class="col-sm-3">Address</dt>
						<dd class="col-sm-9">
							<cfif len( prc.client.address )>
								#replace( encodeForHTML( prc.client.address ), chr(10), "<br>", "all" )#
							<cfelse>
								<span class="text-muted">Not provided</span>
							</cfif>
						</dd>

						<dt class="col-sm-3">Added</dt>
						<dd class="col-sm-9">#formatAppDate( prc.client.created_at )#</dd>
					</dl>
				</div>
			</div>
		</div>

		<div class="col-md-6">
			<div class="card mb-4">
				<div class="card-header d-flex justify-content-between align-items-center">
					<h5 class="mb-0">Contracts</h5>
					<a href="#event.buildLink( 'contracts.new' )#?client_id=#prc.client.id#" class="btn btn-sm btn-primary">
						<i class="bi bi-plus-lg"></i> Add Contract
					</a>
				</div>
				<div class="card-body">
					<cfif prc.contracts.recordCount>
						<table class="table table-sm mb-0">
							<thead>
								<tr>
									<th>Name</th>
									<th>Rate</th>
									<th>Status</th>
								</tr>
							</thead>
							<tbody>
								<cfloop query="prc.contracts">
									<tr>
										<td>
											<a href="#event.buildLink( 'contracts' )#/#prc.contracts.id#">
												#encodeForHTML( prc.contracts.name )#
											</a>
										</td>
										<td>#formatCurrency( prc.contracts.hourly_rate )#/hr</td>
										<td>#statusBadge( prc.contracts.status )#</td>
									</tr>
								</cfloop>
							</tbody>
						</table>
					<cfelse>
						<p class="text-muted mb-0">No contracts yet.</p>
					</cfif>
				</div>
			</div>

			<div class="card">
				<div class="card-header d-flex justify-content-between align-items-center">
					<h5 class="mb-0">Tickets</h5>
					<a href="#event.buildLink( 'tickets.new' )#" class="btn btn-sm btn-primary">
						<i class="bi bi-plus-lg"></i> Add Ticket
					</a>
				</div>
				<div class="card-body">
					<cfif prc.tickets.recordCount>
						<table class="table table-sm mb-0">
							<thead>
								<tr>
									<th>Title</th>
									<th>Status</th>
									<th>Priority</th>
								</tr>
							</thead>
							<tbody>
								<cfloop query="prc.tickets">
									<tr>
										<td>
											<a href="#event.buildLink( 'tickets' )#/#prc.tickets.id#">
												#encodeForHTML( prc.tickets.title )#
											</a>
										</td>
										<td>#statusBadge( prc.tickets.status )#</td>
										<td>#statusBadge( prc.tickets.priority )#</td>
									</tr>
								</cfloop>
							</tbody>
						</table>
					<cfelse>
						<p class="text-muted mb-0">No tickets yet.</p>
					</cfif>
				</div>
			</div>
		</div>
	</div>
</div>
</cfoutput>
