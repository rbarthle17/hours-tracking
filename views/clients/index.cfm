<cfoutput>
<div class="container py-4">
	<div class="d-flex justify-content-between align-items-center mb-4">
		<h1><i class="bi bi-people"></i> Clients</h1>
		<a href="#event.buildLink( 'clients.new' )#" class="btn btn-primary">
			<i class="bi bi-plus-lg"></i> New Client
		</a>
	</div>

	<!--- Search --->
	<form method="GET" action="#event.buildLink( 'clients' )#" class="mb-3">
		<div class="input-group" style="max-width: 400px;">
			<input type="text" name="search" class="form-control" placeholder="Search clients..."
				   value="#encodeForHTMLAttribute( rc.search ?: '' )#">
			<button class="btn btn-outline-secondary" type="submit">
				<i class="bi bi-search"></i> Search
			</button>
			<cfif len( rc.search ?: "" )>
				<a href="#event.buildLink( 'clients' )#" class="btn btn-outline-secondary">Clear</a>
			</cfif>
		</div>
	</form>

	<div class="table-responsive">
		<table class="table table-striped table-hover">
			<thead class="table-dark">
				<tr>
					<th>Name</th>
					<th>Email</th>
					<th>Phone</th>
					<th class="text-end">Actions</th>
				</tr>
			</thead>
			<tbody>
				<cfif prc.clients.recordCount>
					<cfloop query="prc.clients">
						<tr>
							<td>
								<a href="#event.buildLink( 'clients' )#/#prc.clients.id#">
									#encodeForHTML( prc.clients.name )#
								</a>
							</td>
							<td>#encodeForHTML( prc.clients.email )#</td>
							<td>#encodeForHTML( prc.clients.phone )#</td>
							<td class="text-end">
								<a href="#event.buildLink( 'clients' )#/#prc.clients.id#"
								   class="btn btn-sm btn-outline-primary">
									<i class="bi bi-eye"></i> View
								</a>
								<a href="#event.buildLink( 'clients' )#/#prc.clients.id#/edit"
								   class="btn btn-sm btn-outline-secondary">
									<i class="bi bi-pencil"></i> Edit
								</a>
							</td>
						</tr>
					</cfloop>
				<cfelse>
					<tr>
						<td colspan="4" class="text-center text-muted py-4">
							<cfif len( rc.search ?: "" )>
								No clients found matching "#encodeForHTML( rc.search )#".
							<cfelse>
								No clients yet. <a href="#event.buildLink( 'clients.new' )#">Add your first client</a>.
							</cfif>
						</td>
					</tr>
				</cfif>
			</tbody>
		</table>
	</div>
</div>
</cfoutput>
