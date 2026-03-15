<cfoutput>
<div class="container py-4">
	<div class="row justify-content-center">
		<div class="col-md-8">
			<div class="d-flex justify-content-between align-items-center mb-4">
				<h1><i class="bi bi-pencil"></i> Edit Ticket</h1>
				<a href="#event.buildLink( 'tickets' )#/#prc.ticket.id#" class="btn btn-outline-secondary">
					<i class="bi bi-arrow-left"></i> Back to Ticket
				</a>
			</div>

			<div class="card">
				<div class="card-body">
					<form method="POST" action="#event.buildLink( 'tickets' )#/#prc.ticket.id#">
						<input type="hidden" name="_method" value="PUT">

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
									<option value="#prc.contracts.id#" #prc.ticket.contract_id EQ prc.contracts.id ? 'selected' : ''#>
										#encodeForHTML( prc.contracts.name )# (#formatCurrency( prc.contracts.hourly_rate )#/hr)
									</option>
								</cfloop>
								<cfif len( currentClient )></optgroup></cfif>
							</select>
						</div>

						<div class="mb-3">
							<label for="title" class="form-label">Title <span class="text-danger">*</span></label>
							<input type="text" class="form-control" id="title" name="title"
								   value="#encodeForHTMLAttribute( prc.ticket.title )#" required>
						</div>

						<div class="mb-3">
							<label for="description" class="form-label">Description</label>
							<textarea class="form-control" id="description" name="description"
									  rows="4">#encodeForHTML( prc.ticket.description ?: '' )#</textarea>
						</div>

						<div class="row mb-3">
							<div class="col-md-6">
								<label for="status" class="form-label">Status</label>
								<select class="form-select" id="status" name="status">
									<option value="open" #prc.ticket.status EQ 'open' ? 'selected' : ''#>Open</option>
									<option value="in_progress" #prc.ticket.status EQ 'in_progress' ? 'selected' : ''#>In Progress</option>
									<option value="done" #prc.ticket.status EQ 'done' ? 'selected' : ''#>Done</option>
									<option value="closed" #prc.ticket.status EQ 'closed' ? 'selected' : ''#>Closed</option>
								</select>
							</div>
							<div class="col-md-6">
								<label for="priority" class="form-label">Priority</label>
								<select class="form-select" id="priority" name="priority">
									<option value="medium" #prc.ticket.priority EQ 'medium' ? 'selected' : ''#>Medium</option>
									<option value="high" #prc.ticket.priority EQ 'high' ? 'selected' : ''#>High</option>
									<option value="low" #prc.ticket.priority EQ 'low' ? 'selected' : ''#>Low</option>
								</select>
							</div>
						</div>

						<div class="d-flex gap-2">
							<button type="submit" class="btn btn-primary">
								<i class="bi bi-check-lg"></i> Update Ticket
							</button>
							<a href="#event.buildLink( 'tickets' )#/#prc.ticket.id#" class="btn btn-outline-secondary">Cancel</a>
						</div>
					</form>
				</div>
			</div>
		</div>
	</div>
</div>
</cfoutput>
