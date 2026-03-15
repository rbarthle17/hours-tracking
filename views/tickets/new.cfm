<cfoutput>
<div class="container py-4">
	<div class="row justify-content-center">
		<div class="col-md-8">
			<div class="d-flex justify-content-between align-items-center mb-4">
				<h1><i class="bi bi-plus-lg"></i> New Ticket</h1>
				<a href="#event.buildLink( 'tickets' )#" class="btn btn-outline-secondary">
					<i class="bi bi-arrow-left"></i> Back to Tickets
				</a>
			</div>

			<div class="card">
				<div class="card-body">
					<form method="POST" action="#event.buildLink( 'tickets' )#">

						<div class="mb-3">
							<label for="contract_id" class="form-label">Contract <span class="text-danger">*</span></label>
							<select class="form-select" id="contract_id" name="contract_id" required>
								<option value="">Select a contract...</option>
								<cfset currentClient = "">
								<cfloop query="prc.contracts">
									<cfif prc.contracts.client_name NEQ currentClient>
										<cfif len( currentClient )></optgroup></cfif>
										<optgroup label="#encodeForHTMLAttribute( prc.contracts.client_name )#">
										<cfset currentClient = prc.contracts.client_name>
									</cfif>
									<option value="#prc.contracts.id#" #val( rc.contract_id ?: 0 ) EQ prc.contracts.id ? 'selected' : ''#>
										#encodeForHTML( prc.contracts.name )# (#formatCurrency( prc.contracts.hourly_rate )#/hr)
									</option>
								</cfloop>
								<cfif len( currentClient )></optgroup></cfif>
							</select>
						</div>

						<div class="mb-3">
							<label for="title" class="form-label">Title <span class="text-danger">*</span></label>
							<input type="text" class="form-control" id="title" name="title"
								   value="#encodeForHTMLAttribute( rc.title ?: '' )#" required>
						</div>

						<div class="mb-3">
							<label for="description" class="form-label">Description</label>
							<textarea class="form-control" id="description" name="description"
									  rows="4">#encodeForHTML( rc.description ?: '' )#</textarea>
						</div>

						<div class="row mb-3">
							<div class="col-md-6">
								<label for="status" class="form-label">Status</label>
								<select class="form-select" id="status" name="status">
									<option value="open" #(rc.status ?: 'open') EQ 'open' ? 'selected' : ''#>Open</option>
									<option value="in_progress" #(rc.status ?: '') EQ 'in_progress' ? 'selected' : ''#>In Progress</option>
									<option value="done" #(rc.status ?: '') EQ 'done' ? 'selected' : ''#>Done</option>
									<option value="closed" #(rc.status ?: '') EQ 'closed' ? 'selected' : ''#>Closed</option>
								</select>
							</div>
							<div class="col-md-6">
								<label for="priority" class="form-label">Priority</label>
								<select class="form-select" id="priority" name="priority">
									<option value="medium" #(rc.priority ?: 'medium') EQ 'medium' ? 'selected' : ''#>Medium</option>
									<option value="high" #(rc.priority ?: '') EQ 'high' ? 'selected' : ''#>High</option>
									<option value="low" #(rc.priority ?: '') EQ 'low' ? 'selected' : ''#>Low</option>
								</select>
							</div>
						</div>

						<div class="d-flex gap-2">
							<button type="submit" class="btn btn-primary">
								<i class="bi bi-check-lg"></i> Create Ticket
							</button>
							<a href="#event.buildLink( 'tickets' )#" class="btn btn-outline-secondary">Cancel</a>
						</div>
					</form>
				</div>
			</div>
		</div>
	</div>
</div>
</cfoutput>
