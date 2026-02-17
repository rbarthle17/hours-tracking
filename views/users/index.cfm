<cfoutput>
<div class="container py-4">
	<div class="d-flex justify-content-between align-items-center mb-4">
		<h1><i class="bi bi-gear"></i> Users</h1>
		<a href="#event.buildLink( 'users.new' )#" class="btn btn-primary">
			<i class="bi bi-plus-lg"></i> New User
		</a>
	</div>

	<div class="table-responsive">
		<table class="table table-striped table-hover">
			<thead class="table-dark">
				<tr>
					<th>Name</th>
					<th>Email</th>
					<th>Role</th>
					<th>Status</th>
					<th>Last Login</th>
					<th class="text-end">Actions</th>
				</tr>
			</thead>
			<tbody>
				<cfif prc.users.recordCount>
					<cfloop query="prc.users">
						<tr>
							<td>#encodeForHTML( prc.users.first_name )# #encodeForHTML( prc.users.last_name )#</td>
							<td>#encodeForHTML( prc.users.email )#</td>
							<td>#statusBadge( prc.users.role )#</td>
							<td>
								<cfif prc.users.is_active>
									<span class="badge bg-success">Active</span>
								<cfelse>
									<span class="badge bg-secondary">Inactive</span>
								</cfif>
							</td>
							<td>
								<cfif len( prc.users.last_login_at ) AND isDate( prc.users.last_login_at )>
									#formatAppDate( prc.users.last_login_at )#
								<cfelse>
									<span class="text-muted">Never</span>
								</cfif>
							</td>
							<td class="text-end">
								<a href="#event.buildLink( 'users' )#/#prc.users.id#/edit"
								   class="btn btn-sm btn-outline-secondary">
									<i class="bi bi-pencil"></i> Edit
								</a>
								<cfif prc.users.id NEQ session.user.id>
									<form method="POST"
										  action="#event.buildLink( 'users' )#/#prc.users.id#"
										  class="d-inline"
										  onsubmit="return confirm( 'Are you sure you want to delete this user?' );">
										<input type="hidden" name="_method" value="DELETE">
										<button type="submit" class="btn btn-sm btn-outline-danger">
											<i class="bi bi-trash"></i> Delete
										</button>
									</form>
								</cfif>
							</td>
						</tr>
					</cfloop>
				<cfelse>
					<tr>
						<td colspan="6" class="text-center text-muted py-4">No users found.</td>
					</tr>
				</cfif>
			</tbody>
		</table>
	</div>
</div>
</cfoutput>
